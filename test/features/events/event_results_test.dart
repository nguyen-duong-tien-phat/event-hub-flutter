import 'dart:async';

import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/auth/data/models/organizer.dart';
import 'package:event_hub_mobile/features/events/data/event_repository.dart';
import 'package:event_hub_mobile/features/events/data/models/event_filters.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/discover_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

EventSummary _event(int n) => EventSummary(
  id: 'e$n',
  title: 'Event $n',
  organizer: const Organizer(id: 'o', fullName: 'Organizer'),
  startsAt: DateTime(2030, 1, n),
  location: 'Somewhere',
  imageUrl: '',
);

/// Serves [totalPages] pages of [perPage] events. Every request waits on a
/// completer the test controls, so a test decides when (and how) it ends.
class _FakeEvents implements EventRepository {
  static const totalPages = 3;
  static const perPage = 2;

  /// The page number of every request, in order.
  final requested = <int>[];
  final _pending = <int, Completer<PaginatedResponse<EventSummary>>>{};

  PaginatedResponse<EventSummary> pageOf(int page, {int? firstItem}) {
    final start = firstItem ?? (page - 1) * perPage + 1;
    return PaginatedResponse(
      items: [for (var i = 0; i < perPage; i++) _event(start + i)],
      page: page,
      pageSize: perPage,
      totalCount: totalPages * perPage,
      totalPages: totalPages,
    );
  }

  /// Answers the oldest unanswered request for [page].
  void complete(int page, {int? firstItem}) =>
      _pending[page]!.complete(pageOf(page, firstItem: firstItem));

  void fail(int page) => _pending[page]!.completeError(Exception('offline'));

  @override
  Future<PaginatedResponse<EventSummary>> getEvents({
    int page = 1,
    int pageSize = 10,
    DateTime? from,
    DateTime? to,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) {
    requested.add(page);
    return (_pending[page] = Completer()).future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeEvents fake;
  late ProviderContainer container;

  final provider = eventResultsProvider(const EventFilters(), '');

  setUp(() {
    fake = _FakeEvents();
    container = ProviderContainer(
      overrides: [eventRepositoryProvider.overrideWithValue(fake)],
    );
    // Auto-dispose providers would be dropped between reads otherwise.
    container.listen(provider, (_, _) {});
    addTearDown(container.dispose);
  });

  /// Loads the first page and returns once it is in.
  Future<void> loadFirstPage() async {
    final first = container.read(provider.future);
    fake.complete(1);
    await first;
  }

  test('first page: shows its items and knows there is more', () async {
    await loadFirstPage();

    final state = container.read(provider).requireValue;
    expect(state.items.map((e) => e.id), ['e1', 'e2']);
    expect(state.totalCount, 6);
    expect(state.hasMore, isTrue);
    expect(state.isLoadingMore, isFalse);
    expect(fake.requested, [1]);
  });

  test('loadMore appends the next page after the loaded items', () async {
    await loadFirstPage();

    final loading = container.read(provider.notifier).loadMore();
    expect(container.read(provider).requireValue.isLoadingMore, isTrue);
    fake.complete(2);
    await loading;

    final state = container.read(provider).requireValue;
    expect(state.items.map((e) => e.id), ['e1', 'e2', 'e3', 'e4']);
    expect(state.isLoadingMore, isFalse);
    expect(fake.requested, [1, 2]);
  });

  test('stops asking once the last page is loaded', () async {
    await loadFirstPage();
    final notifier = container.read(provider.notifier);

    final second = notifier.loadMore();
    fake.complete(2);
    await second;
    final third = notifier.loadMore();
    fake.complete(3);
    await third;

    expect(container.read(provider).requireValue.hasMore, isFalse);
    await notifier.loadMore();
    expect(fake.requested, [1, 2, 3]);
  });

  test('ignores loadMore while the first page is still loading', () async {
    await container.read(provider.notifier).loadMore();

    expect(fake.requested, [1]);
  });

  test('ignores loadMore calls while a page is already loading', () async {
    await loadFirstPage();
    final notifier = container.read(provider.notifier);

    final a = notifier.loadMore();
    final b = notifier.loadMore();
    final c = notifier.loadMore();
    fake.complete(2);
    await Future.wait([a, b, c]);

    expect(fake.requested, [1, 2]);
    expect(container.read(provider).requireValue.items, hasLength(4));
  });

  test('a failed loadMore keeps the items, and retrying works', () async {
    await loadFirstPage();
    final notifier = container.read(provider.notifier);

    final failing = notifier.loadMore();
    fake.fail(2);
    await failing;

    var state = container.read(provider).requireValue;
    expect(container.read(provider).hasError, isFalse);
    expect(state.items.map((e) => e.id), ['e1', 'e2']);
    expect(state.loadMoreError, isNotNull);
    expect(state.isLoadingMore, isFalse);

    final retry = notifier.loadMore();
    expect(container.read(provider).requireValue.loadMoreError, isNull);
    fake.complete(2);
    await retry;

    state = container.read(provider).requireValue;
    expect(state.items.map((e) => e.id), ['e1', 'e2', 'e3', 'e4']);
    expect(state.loadMoreError, isNull);
    expect(fake.requested, [1, 2, 2]);
  });

  test('an item that slid over a page border is not listed twice', () async {
    await loadFirstPage();

    final loading = container.read(provider.notifier).loadMore();
    // The server list changed: page 2 now starts with e2 again.
    fake.complete(2, firstItem: 2);
    await loading;

    final ids = container.read(provider).requireValue.items.map((e) => e.id);
    expect(ids, ['e1', 'e2', 'e3']);
  });

  test('a page that arrives after a refresh is thrown away', () async {
    await loadFirstPage();
    final notifier = container.read(provider.notifier);

    final stale = notifier.loadMore(); // page 2 of the old list
    container.invalidate(provider);
    final refreshed = container.read(provider.future);
    fake.complete(1, firstItem: 10); // the reloaded first page
    await refreshed;

    fake.complete(2); // the old page 2 finally comes back
    await stale;

    final state = container.read(provider).requireValue;
    expect(state.items.map((e) => e.id), ['e10', 'e11']);
    expect(state.isLoadingMore, isFalse);
  });
}
