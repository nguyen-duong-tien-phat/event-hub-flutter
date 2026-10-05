class Ticket {
  final String id;
  final String eventId;
  final String type;
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
    required this.highlights,
    required this.maxPerOrder,
  });

  factory fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      eventId: json['eventId'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      totalQuantity: json['totalQuantity'],
      remainingQuantity: json['remainingQuantity'],
      highlights: List<String>.from(json['highlights']),
      maxPerOrder: json['maxPerOrder'],
    );
  }
}
