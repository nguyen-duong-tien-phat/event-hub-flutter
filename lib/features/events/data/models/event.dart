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
}
