import 'package:intl/intl.dart';

enum UserRole { admin, attendee, organizer }

class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });
}

class Ticket {
  final String id;
  final String eventId; // reference only — avoids circular Event <-> Ticket
  final String type; // e.g. "General", "VIP"
  final double price;
  final int totalQuantity;
  final int remainingQuantity;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.type,
    required this.price,
    required this.totalQuantity,
    required this.remainingQuantity,
  });

  bool get isSoldOut => remainingQuantity <= 0;
}

class Event {
  final String id; // Guid -> String on the Dart side
  final String title;
  final String description;
  final DateTime startsAt;
  final String location;
  final String organizerId;
  final User? organizer;
  final List<Ticket> tickets;

  // Not part of the backend entity yet — kept as a frontend-only
  // field until the API provides a real image URL.
  final String imageUrl;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.location,
    required this.organizerId,
    this.organizer,
    this.tickets = const [],
    required this.imageUrl,
  });

  // Derived display helpers — keeps formatting logic out of the widget.
  String get formattedDate => DateFormat('d MMM').format(startsAt);
  String get formattedTime => DateFormat('h:mm a').format(startsAt);

  /// Lowest ticket price, formatted for display.
  /// Returns null if there are no tickets yet (e.g. not on sale).
  String? get formattedPrice {
    if (tickets.isEmpty) return null;
    final lowest = tickets.map((t) => t.price).reduce((a, b) => a < b ? a : b);
    return '\$${lowest.toStringAsFixed(2)}';
  }
}

// Mock data for now — replace with a real API/repository call later.
final List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'Oliver Tree Concert',
    description: 'Oliver Tree live in Jakarta.',
    startsAt: DateTime(2026, 12, 29, 22, 0),
    location: 'Jakarta, Indonesia',
    organizerId: 'org-1',
    organizer: const User(
      id: 'org-1',
      email: 'contact@livenation.id',
      fullName: 'Live Nation Indonesia',
      role: UserRole.organizer,
    ),
    tickets: const [
      Ticket(
        id: 't1',
        eventId: '1',
        type: 'General',
        price: 45.90,
        totalQuantity: 500,
        remainingQuantity: 120,
      ),
      Ticket(
        id: 't2',
        eventId: '1',
        type: 'VIP',
        price: 89.00,
        totalQuantity: 100,
        remainingQuantity: 12,
      ),
    ],
    imageUrl:
        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
  ),
  Event(
    id: '2',
    title: 'Halloween Night',
    description: 'A spooky night out.',
    startsAt: DateTime(2026, 3, 22, 20, 0),
    location: 'Bandung, Indonesia',
    organizerId: 'org-2',
    organizer: const User(
      id: 'org-2',
      email: 'hello@nightlife.co',
      fullName: 'Nightlife Co.',
      role: UserRole.organizer,
    ),
    tickets: const [
      Ticket(
        id: 't3',
        eventId: '2',
        type: 'General',
        price: 30.00,
        totalQuantity: 300,
        remainingQuantity: 40,
      ),
    ],
    imageUrl:
        'https://images.unsplash.com/photo-1509557965875-b88c97052f0e?w=800',
  ),
];
