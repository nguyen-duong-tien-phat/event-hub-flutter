import 'package:event_hub_mobile/features/auth/data/models/organizer.dart';
import 'package:intl/intl.dart';

class EventSummary {
  final String id;
  final String title;
  final DateTime startsAt;
  final String location;
  final String imageUrl;
  final Organizer organizer;

  const EventSummary({
    required this.id,
    required this.title,
    required this.organizer,
    required this.startsAt,
    required this.location,
    required this.imageUrl,
  });

  factory fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'],
      title: json['title'],
      organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>),
      startsAt: DateTime.parse(json['startsAt']),
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }

  String get time => DateFormat('Hm').format(startsAt);
  String get month => DateFormat('MMM').format(startsAt);
  String get day => DateFormat('dd').format(startsAt);
  String get date => DateFormat('E dd MMM').format(startsAt);
}
