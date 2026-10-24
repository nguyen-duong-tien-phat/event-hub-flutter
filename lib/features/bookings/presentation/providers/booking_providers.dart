import 'package:event_hub_mobile/features/bookings/data/booking_repository.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'booking_providers.g.dart';

@riverpod
Future<Booking> booking(Ref ref, String id) {
  return ref.watch(bookingRepositoryProvider).getById(id);
}

/// The signed-in user's bookings, newest first (the Tickets tab).
@riverpod
Future<List<Booking>> myBookings(Ref ref) async {
  final page = await ref.watch(bookingRepositoryProvider).mine(pageSize: 50);
  return page.items.reversed.toList();
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
