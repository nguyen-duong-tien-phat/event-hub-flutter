class Ticket {
  final String id;
  final String eventId; // reference only — avoids circular Event <-> Ticket
  final String type; // e.g. "General", "VIP"
  final double price;
  final int totalQuantity;
  final int remainingQuantity;
  final List<String> highlights;
  final int maxPerOrder;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.type,
    required this.price,
    required this.totalQuantity,
    required this.remainingQuantity,
    this.highlights = const [],
    required this.maxPerOrder,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      eventId: json['eventId'],
      type: json['type'],
      price: json['price'],
      totalQuantity: json['totalQuantity'],
      remainingQuantity: json['remainingQuantity'],
      maxPerOrder: json['maxPerOrder'] ?? 2,
      highlights: (json['highlights'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
    );
  }

  bool get isSoldOut => remainingQuantity <= 0;

  /// The actual max a person can select right now — whichever is
  /// smaller: what's left in stock, or the per-order cap.
  int get effectiveMaxQuantity =>
      remainingQuantity < maxPerOrder ? remainingQuantity : maxPerOrder;
}
