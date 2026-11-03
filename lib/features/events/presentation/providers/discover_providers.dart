import 'package:event_hub_mobile/core/network/paged_state.dart';
import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/events/data/event_repository.dart';
import 'package:event_hub_mobile/features/events/data/models/event_filters.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_providers.g.dart';

/// The filters chosen on Discover. Search uses them too, so what you narrowed
/// down stays narrowed down when you start typing.
@Riverpod(keepAlive: true)
class DiscoverFilters extends _$DiscoverFilters {
  @override
  EventFilters build() => const EventFilters();

  void set(EventFilters filters) => state = filters;

  void reset() => state = const EventFilters();
}

/// The categories to filter by, as the backend stores them.
@riverpod
Future<List<String>> eventCategories(Ref ref) =>
    ref.watch(eventRepositoryProvider).getCategories();

/// How many events one request asks for.
const eventsPageSize = 20;

/// Events matching [filters] and the text [query], soonest first. Starts with
/// the first page; [loadMore] adds the next ones to the end.
@riverpod
class EventResults extends _$EventResults {
  /// Counts rebuilds. A page that comes back after the list was reloaded (a
  /// pull to refresh, say) belongs to the old list and must be thrown away.
  int _generation = 0;

  /// The date window of the first request. Later pages reuse it, so "from now"
  /// does not creep forward between pages and shuffle the list.
  late ({DateTime from, DateTime? to}) _range;

  @override
  Future<PagedState<EventSummary>> build(
    EventFilters filters,
    String query,
  ) async {
    _generation++;
    // Watched so the list reloads if the repository is ever rebuilt.
    ref.watch(eventRepositoryProvider);
    _range = filters.dateRange(DateTime.now());
    return PagedState.first(await _fetch(1));
  }

  Future<PaginatedResponse<EventSummary>> _fetch(int page) {
    return ref
        .read(eventRepositoryProvider)
        .getEvents(
          page: page,
          pageSize: eventsPageSize,
          from: _range.from,
          to: _range.to,
          search: query.trim(),
          category: filters.category,
          minPrice: filters.minPrice,
          maxPrice: filters.maxPrice,
        );
  }

  /// Loads the next page. Does nothing while a page is already on its way, when
  /// the last page is reached, or while the first page is still loading. Also
  /// the "retry" after a failed attempt.
  Future<void> loadMore() async {
    final current = state.value;
    if (state.isLoading || current == null) return;
    if (!current.hasMore || current.isLoadingMore) return;

    final generation = _generation;
    state = AsyncData(current.loading());

    try {
      final response = await _fetch(current.nextPage);
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(current.appended(response, idOf: (e) => e.id));
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(current.failed(error));
    }
  }
}
