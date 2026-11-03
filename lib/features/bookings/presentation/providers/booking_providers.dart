import 'package:event_hub_mobile/core/network/paged_state.dart';
import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/bookings/data/booking_repository.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'booking_providers.g.dart';

@riverpod
Future<Booking> booking(Ref ref, String id) {
  return ref.watch(bookingRepositoryProvider).getById(id);
}

/// How many bookings one request asks for.
const bookingsPageSize = 20;

/// The signed-in user's bookings (the Tickets tab), one page at a time.
///
/// The backend does not promise an order for this list, and the Tickets screen
/// sorts by event date itself, so the order here does not matter.
@riverpod
class MyBookings extends _$MyBookings {
  /// Counts rebuilds, so a page that arrives after a refresh is thrown away.
  int _generation = 0;

  @override
  Future<PagedState<Booking>> build() async {
    _generation++;
    ref.watch(bookingRepositoryProvider);
    return PagedState.first(await _fetch(1));
  }

  Future<PaginatedResponse<Booking>> _fetch(int page) => ref
      .read(bookingRepositoryProvider)
      .mine(page: page, pageSize: bookingsPageSize);

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
      state = AsyncData(current.appended(response, idOf: (b) => b.id));
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(current.failed(error));
    }
  }
}

/// Stripe client secrets by booking id. The backend only sends a secret when a
/// booking is created, so it is kept here until the payment is done.
@Riverpod(keepAlive: true)
class PaymentSecrets extends _$PaymentSecrets {
  @override
  Map<String, String> build() => {};

  void put(String bookingId, String secret) =>
      state = {...state, bookingId: secret};
}

/// Bookings whose Stripe payment sheet is open right now. While a booking is
/// in here nothing may cancel it, or the customer could pay for tickets that
/// were already given back.
@Riverpod(keepAlive: true)
class PaymentsInProgress extends _$PaymentsInProgress {
  @override
  Set<String> build() => {};

  void start(String bookingId) => state = {...state, bookingId};

  void finish(String bookingId) =>
      state = state.where((id) => id != bookingId).toSet();
}
