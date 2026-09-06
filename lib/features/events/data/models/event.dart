import 'package:event_hub_mobile/features/tickets/data/models/ticket.dart';
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

  // Also frontend-only for now — short bullet points shown under the
  // description (matches the reference design's checklist section).
  // Wire this to a real backend field once one exists.
  final List<String> highlights;

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
    this.highlights = const [],
  });

  // Derived display helpers — keeps formatting logic out of the widget.
  String get formattedDate => DateFormat('d MMM').format(startsAt);
  String get formattedTime => DateFormat('h:mm a').format(startsAt);
  String get dayNumber => DateFormat('d').format(startsAt);
  String get monthAbbreviated =>
      DateFormat('MMM').format(startsAt).toUpperCase();
  String get weekdayFull => DateFormat('EEEE').format(startsAt);

  /// Ticket price display. Since an event can have multiple ticket
  /// types at different prices, this shows a range ("From $X" when
  /// there's one price, "$X - $Y" when there are several).
  /// Returns null if there are no tickets yet (e.g. not on sale).
  String? get formattedPrice {
    if (tickets.isEmpty) return null;
    final prices = tickets.map((t) => t.price).toSet().toList()..sort();
    if (prices.length == 1) {
      return '\$${prices.first.toStringAsFixed(2)}';
    }
    return '\$${prices.first.toStringAsFixed(2)} - \$${prices.last.toStringAsFixed(2)}';
  }
}

// Mock data for now — replace with a real API/repository call later.
final List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'Oliver Tree Concert',
    description:
        'Oliver Tree brings his genre-bending live show to Jakarta for one night only. '
        'Known for blending alternative rock, hip-hop, and electronic influences, expect '
        'a high-energy set featuring fan favorites along with cuts from his latest album. '
        'This is a standing venue — arrive early for the best spot near the stage.',
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
        maxPerOrder: 2,
        totalQuantity: 500,
        remainingQuantity: 120,
        highlights: ['Standing area access', 'Entry from 9:30 PM'],
      ),
      Ticket(
        id: 't2',
        eventId: '1',
        type: 'VIP',
        price: 89.00,
        maxPerOrder: 2,
        totalQuantity: 100,
        remainingQuantity: 12,
        highlights: [
          'Meet and greet with Oliver Tree',
          'Front-stage viewing area',
          'Exclusive tour merchandise',
        ],
      ),
    ],
    imageUrl:
        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
    highlights: const [
      'Oliver Tree performs live starting 10:00 PM',
      'Meet and greet available for VIP ticket holders',
      'Doors open one hour before showtime',
    ],
  ),
];
