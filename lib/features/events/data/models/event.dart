import 'package:event_hub_mobile/features/auth/data/models/organizer.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/tickets/data/models/ticket.dart';

class Event extends EventSummary {
  final String description;
  final List<String> highlights;
  final List<Ticket> tickets;

  const Event({
    required super.id,
    required super.title,
    required super.organizer,
    required super.startsAt,
    required super.location,
    required super.imageUrl,
    required this.description,
    required this.highlights,
    required this.tickets,
  });

  factory fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>),
      startsAt: DateTime.parse(json['startsAt'] as String),
      location: json['location'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      highlights: List<String>.from(json['highlights'] as List),
      tickets: (json['tickets'] as List)
          .map((item) => Ticket.fromJson(item))
          .toList(),
    );
  }
}
