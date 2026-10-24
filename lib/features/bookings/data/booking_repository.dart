import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/core/network/network_provider.dart';
import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'booking_repository.g.dart';

class BookingRepository {
  BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  static Booking _parse(dynamic json) =>
      Booking.fromJson(json as Map<String, dynamic>);

  /// Holds the tickets and starts the payment. [quantities] maps ticket id to
  /// how many of that ticket. The result carries the Stripe client secret.
  ///
  /// [idempotencyKey] identifies one intent to book. Sending the same key again
  /// (a double tap, a retry after a network error) returns the original booking
  /// instead of holding the tickets twice.
  Future<Booking> create(
    String eventId,
    Map<String, int> quantities, {
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      '/bookings',
      headers: {'Idempotency-Key': idempotencyKey},
      data: {
        'eventId': eventId,
        'tickets': [
          for (final entry in quantities.entries)
            {'ticketId': entry.key, 'quantity': entry.value},
        ],
      },
      parser: _parse,
    );
  }

  Future<Booking> getById(String id) =>
      _apiClient.get('/bookings/$id', parser: _parse);

  /// Asks the backend to check the payment with Stripe and confirm the booking
  /// if it was paid.
  Future<Booking> confirm(String id) =>
      _apiClient.post('/bookings/$id/confirm', parser: _parse);

  /// Cancels the booking and gives its tickets back.
  Future<Booking> cancel(String id) =>
      _apiClient.patch('/bookings/$id/cancel', parser: _parse);

  /// Gives the tickets back if the booking has not been paid, e.g. when the
  /// user leaves checkout. Checks first, so a paid booking is never cancelled.
  /// Errors are ignored: this is cleanup, and the backend expires holds anyway.
  Future<void> releaseIfPending(String id) async {
    try {
      final booking = await getById(id);
      if (booking.isPending) await cancel(id);
    } catch (_) {}
  }

  Future<PaginatedResponse<Booking>> mine({int page = 1, int pageSize = 20}) {
    return _apiClient.get(
      '/bookings/me',
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: (json) => PaginatedResponse.fromJson(
        json as Map<String, dynamic>,
        Booking.fromJson,
      ),
    );
  }
}

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(apiClientProvider));
}
