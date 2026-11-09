/// Sales of one ticket type.
class TicketStats {
  const TicketStats({
    required this.ticketId,
    required this.type,
    required this.price,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.sold,
    required this.held,
  });

  final String ticketId;
  final String type;
  final double price;
  final int totalQuantity;
  final int remainingQuantity;

  /// In paid bookings.
  final int sold;

  /// Taken out of stock by bookings still waiting for payment.
  final int held;

  factory TicketStats.fromJson(Map<String, dynamic> json) => TicketStats(
    ticketId: json['ticketId'] as String,
    type: json['type'] as String,
    price: (json['price'] as num).toDouble(),
    totalQuantity: json['totalQuantity'] as int,
    remainingQuantity: json['remainingQuantity'] as int,
    sold: json['sold'] as int,
    held: json['held'] as int,
  );

  double get soldFraction =>
      totalQuantity == 0 ? 0 : (sold / totalQuantity).clamp(0, 1).toDouble();
}

/// What the organizer sees for one event. Only paid bookings count as sales.
class EventStats {
  const EventStats({
    required this.eventId,
    required this.pending,
    required this.confirmed,
    required this.cancelled,
    required this.ticketRevenue,
    required this.ticketsSold,
    required this.checkedIn,
    required this.tickets,
  });

  final String eventId;
  final int pending;
  final int confirmed;
  final int cancelled;

  /// Without the service fee.
  final double ticketRevenue;
  final int ticketsSold;
  final int checkedIn;
  final List<TicketStats> tickets;

  factory EventStats.fromJson(Map<String, dynamic> json) {
    final bookings = json['bookings'] as Map<String, dynamic>;
    return EventStats(
      eventId: json['eventId'] as String,
      pending: bookings['pending'] as int,
      confirmed: bookings['confirmed'] as int,
      cancelled: bookings['cancelled'] as int,
      ticketRevenue: (json['ticketRevenue'] as num).toDouble(),
      ticketsSold: json['ticketsSold'] as int,
      checkedIn: json['checkedIn'] as int,
      tickets: (json['tickets'] as List)
          .map((t) => TicketStats.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  int get held => tickets.fold(0, (sum, t) => sum + t.held);
}
