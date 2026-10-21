import 'package:event_hub_mobile/features/auth/data/models/organizer.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/tickets/data/models/ticket.dart';

class Event extends EventSummary {
  final String description;
  final List<String> highlights;
  final List<Ticket> tickets;
  final DateTime? endsAt;
  final DateTime? doorsOpenAt;
  final String? ageRestriction;
  final String? refundPolicy;

  const Event({
    required super.id,
    required super.title,
    required super.organizer,
    required super.startsAt,
    required super.location,
    required super.imageUrl,
    super.category,
    required this.description,
    required this.highlights,
    required this.tickets,
    this.endsAt,
    this.doorsOpenAt,
    this.ageRestriction,
    this.refundPolicy,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>),
      startsAt: DateTime.parse(json['startsAt'] as String),
      location: json['location'],
      imageUrl: json['imageUrl'],
      category: json['category'] as String? ?? '',
      description: json['description'],
      highlights: List<String>.from(json['highlights'] as List),
      tickets: (json['tickets'] as List)
          .map((item) => Ticket.fromJson(item))
          .toList(),
      endsAt: _date(json['endsAt']),
      doorsOpenAt: _date(json['doorsOpenAt']),
      ageRestriction: json['ageRestriction'] as String?,
      refundPolicy: json['refundPolicy'] as String?,
    );
  }

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
