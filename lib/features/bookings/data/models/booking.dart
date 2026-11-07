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
      startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
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

/// One person's entry to the event: its own QR, a short code to type, and whether it was used.
class Admission {
  const Admission({
    required this.id,
    required this.ticketType,
    required this.code,
    required this.shortCode,
    this.checkedInAt,
  });

  final String id;
  final String ticketType;

  /// Signed QR contents. The app cannot make a valid one itself.
  final String code;

  /// "K7Q49XMD", for staff to type when the QR does not scan.
  final String shortCode;
  final DateTime? checkedInAt;

  bool get isCheckedIn => checkedInAt != null;

  /// "K7Q4 9XMD"
  String get shortCodeLabel => shortCode.length == 8
      ? '${shortCode.substring(0, 4)} ${shortCode.substring(4)}'
      : shortCode;

  factory Admission.fromJson(Map<String, dynamic> json) {
    final at = json['checkedInAt'] as String?;
    return Admission(
      id: json['id'],
      ticketType: json['ticketType'] as String? ?? '',
      code: json['code'],
      shortCode: json['shortCode'] as String? ?? '',
      checkedInAt: at == null ? null : DateTime.parse(at).toLocal(),
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
    this.admissions = const [],
    this.checkedInCount = 0,
    this.canCancel = true,
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

  /// One per person admitted. The backend only sends them once the booking is confirmed.
  final List<Admission> admissions;
  final int checkedInCount;

  /// False once a ticket was used (the backend then refuses to cancel).
  final bool canCancel;

  /// Stripe client secret to pay with. Only sent when the booking is created.
  final String? clientSecret;

  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;

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
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      expiresAt: DateTime.parse(json['expiresAt'] as String).toLocal(),
      admissions: (json['admissions'] as List? ?? const [])
          .map((a) => Admission.fromJson(a as Map<String, dynamic>))
          .toList(),
      checkedInCount: json['checkedInCount'] as int? ?? 0,
      canCancel: json['canCancel'] as bool? ?? true,
      clientSecret: json['clientSecret'] as String?,
    );
  }
}
