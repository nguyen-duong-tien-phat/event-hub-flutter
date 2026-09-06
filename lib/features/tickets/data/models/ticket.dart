class Ticket {
  final String id;
  final String eventId; // reference only — avoids circular Event <-> Ticket
  final String type; // e.g. "General", "VIP"
  final double price;
  final int totalQuantity;
  final int remainingQuantity;

  // Frontend-only for now, like Event.highlights — short perks specific
  // to this ticket type (e.g. VIP gets meet & greet, General doesn't).
  // Wire this to a real backend field once one exists.
  final List<String> highlights;

  // A per-order purchase cap, independent of remaining stock (e.g.
  // "max 4 per order" even if 200 are still available) — common
  // anti-scalping rule on real ticketing platforms. Frontend-only for
  // now; wire to a backend field once one exists.
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

  bool get isSoldOut => remainingQuantity <= 0;

  /// The actual max a person can select right now — whichever is
  /// smaller: what's left in stock, or the per-order cap.
  int get effectiveMaxQuantity =>
      remainingQuantity < maxPerOrder ? remainingQuantity : maxPerOrder;
}
