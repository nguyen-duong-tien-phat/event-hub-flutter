enum BookingStatus {
  pending,
  confirmed,
  cancelled;

  static BookingStatus parse(String value) => BookingStatus.values.firstWhere(
    (s) => s.name == value.toLowerCase(),
    orElse: () => BookingStatus.pending,
  );
}

/// The event a booking is for, as the backend sends it with the booking.
class BookingEvent {
  const BookingEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.location,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String location;
  final String imageUrl;

  factory BookingEvent.fromJson(Map<String, dynamic> json) {
    return BookingEvent(
      id: json['id'],
      title: json['title'],
      startsAt: DateTime.parse(json['startsAt'] as String),
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }
}

class BookingTicketItem {
  const BookingTicketItem({
    required this.ticketId,
    required this.type,
    required this.quantity,
    required this.unitPrice,
  });

  final String ticketId;
  final String type;
  final int quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;

  factory BookingTicketItem.fromJson(Map<String, dynamic> json) {
    return BookingTicketItem(
      ticketId: json['ticketId'],
      type: json['type'] as String? ?? '',
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.eventId,
    required this.event,
    required this.tickets,
    required this.quantity,
    required this.subtotal,
    required this.serviceFee,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.clientSecret,
  });

  final String id;
  final String eventId;
  final BookingEvent? event;
  final List<BookingTicketItem> tickets;
  final int quantity;
  final double subtotal;
  final double serviceFee;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  /// While pending, the tickets are held until this time.
  final DateTime expiresAt;

  /// Stripe client secret to pay with. Only sent when the booking is created.
  final String? clientSecret;

  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Short code to show people, e.g. "EH-3F9A2C".
  String get orderNumber => 'EH-${id.substring(id.length - 6).toUpperCase()}';

  /// "2 × General, 1 × VIP"
  String get ticketsSummary =>
      tickets.map((t) => '${t.quantity} × ${t.type}').join(', ');

  factory Booking.fromJson(Map<String, dynamic> json) {
    final event = json['event'];
    return Booking(
      id: json['id'],
      eventId: json['eventId'],
      event: event == null
          ? null
          : BookingEvent.fromJson(event as Map<String, dynamic>),
      tickets: (json['tickets'] as List)
          .map((t) => BookingTicketItem.fromJson(t as Map<String, dynamic>))
          .toList(),
      quantity: json['quantity'],
      subtotal: (json['subtotal'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.parse(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      clientSecret: json['clientSecret'] as String?,
    );
  }
}
