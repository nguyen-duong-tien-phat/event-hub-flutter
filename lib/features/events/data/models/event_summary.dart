import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:intl/intl.dart';

class EventSummary {
  final String id;
  final String title;
  final DateTime startsAt;
  final String location;
  final String imageUrl;
  final User organizer;

  const EventSummary({
    required this.id,
    required this.title,
    required this.organizer,
    required this.startsAt,
    required this.location,
    required this.imageUrl,
  });

  String get time => DateFormat('Hm').format(startsAt);
  String get month => DateFormat('MMM').format(startsAt);
  String get day => DateFormat('dd').format(startsAt);
  String get date => DateFormat('E dd MMM').format(startsAt);
}
