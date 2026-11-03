import 'dart:async';

import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/bookings/data/booking_repository.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _booking(int n) => Booking.fromJson({
  'id': 'booking-$n',
  'eventId': 'e$n',
  'tickets': <Object>[],
  'quantity': 1,
  'subtotal': 10,
  'serviceFee': 1,
  'totalPrice': 11,
  'status': 'Confirmed',
  'createdAt': '2030-01-01T10:00:00Z',
  'expiresAt': '2030-01-01T10:15:00Z',
});

/// Two pages of two bookings; each request waits for the test to answer it.
class _FakeBookings implements BookingRepository {
  final requested = <int>[];
  final _pending = <int, Completer<PaginatedResponse<Booking>>>{};

  void complete(int page) => _pending[page]!.complete(
    PaginatedResponse(
      items: [_booking(page * 2 - 1), _booking(page * 2)],
      page: page,
      pageSize: 2,
      totalCount: 4,
      totalPages: 2,
    ),
  );

  void fail(int page) => _pending[page]!.completeError(Exception('offline'));

  @override
  Future<PaginatedResponse<Booking>> mine({int page = 1, int pageSize = 20}) {
    requested.add(page);
    return (_pending[page] = Completer()).future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeBookings fake;
  late ProviderContainer container;

  setUp(() {
    fake = _FakeBookings();
    container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(fake)],
    );
    container.listen(myBookingsProvider, (_, _) {});
    addTearDown(container.dispose);
  });

  Future<void> loadFirstPage() async {
    final first = container.read(myBookingsProvider.future);
    fake.complete(1);
    await first;
  }

  test('loads the first page, then appends the next and stops', () async {
    await loadFirstPage();
    final notifier = container.read(myBookingsProvider.notifier);
    expect(container.read(myBookingsProvider).requireValue.hasMore, isTrue);

    final loading = notifier.loadMore();
    fake.complete(2);
    await loading;
    await notifier.loadMore(); // nothing left, so no request

    final state = container.read(myBookingsProvider).requireValue;
    expect(state.items.map((b) => b.id), [
      'booking-1',
      'booking-2',
      'booking-3',
      'booking-4',
    ]);
    expect(state.hasMore, isFalse);
    expect(fake.requested, [1, 2]);
  });

  test('ignores concurrent loadMore calls', () async {
    await loadFirstPage();
    final notifier = container.read(myBookingsProvider.notifier);

    final a = notifier.loadMore();
    final b = notifier.loadMore();
    fake.complete(2);
    await Future.wait([a, b]);

    expect(fake.requested, [1, 2]);
  });

  test('a failed loadMore keeps the loaded bookings', () async {
    await loadFirstPage();

    final failing = container.read(myBookingsProvider.notifier).loadMore();
    fake.fail(2);
    await failing;

    final state = container.read(myBookingsProvider).requireValue;
    expect(state.items, hasLength(2));
    expect(state.loadMoreError, isNotNull);
  });
}
