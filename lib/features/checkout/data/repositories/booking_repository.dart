import 'package:event_hub_mobile/core/network/base_repository.dart';
import 'package:event_hub_mobile/features/checkout/data/models/booking_ticket.dart';

class BookingRepository extends BaseRepository {
  BookingRepository({super.apiClient});

  Future<void> createBooking({
    required String eventId,
    required List<BookingTicket> tickets,
  }) {
    return handleRequest(() async {
      await apiClient.dio.post(
        '/bookings',
        data: {
          'eventId': eventId,
          'tickets': tickets.map((ticket) => ticket.toJson()).toList(),
        },
      );
    });
  }
}
