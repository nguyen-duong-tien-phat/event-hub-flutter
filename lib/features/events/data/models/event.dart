import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/tickets/data/models/ticket.dart';
import 'package:intl/intl.dart';

class Event {
  final String id; // Guid -> String on the Dart side
  final String title;
  final String description;
  final DateTime startsAt;
  final String location;
  final User? organizer;
  final List<Ticket> tickets;
  final String imageUrl;
  final List<String> highlights;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.location,
    this.organizer,
    this.tickets = const [],
    required this.imageUrl,
    this.highlights = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startsAt: DateTime.parse(json['startsAt'] as String),
      location: json['location'],
      organizer: json['organizer'] == null
          ? null
          : User.fromJson(json['organizer']),
      imageUrl: json['imageUrl'],
      highlights: (json['highlights'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),

      tickets: (json['tickets'] as List<dynamic>? ?? [])
          .map((ticket) => Ticket.fromJson(ticket as Map<String, dynamic>))
          .toList(),
    );
  }

  // Derived display helpers — keeps formatting logic out of the widget.
  String get formattedDate => DateFormat('d MMM').format(startsAt);
  String get formattedTime => DateFormat('h:mm a').format(startsAt);
  String get dayNumber => DateFormat('d').format(startsAt);
  String get monthAbbreviated =>
      DateFormat('MMM').format(startsAt).toUpperCase();
  String get weekdayFull => DateFormat('EEEE').format(startsAt);
  String get fullDate => DateFormat('MMMM d, y').format(startsAt);

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
