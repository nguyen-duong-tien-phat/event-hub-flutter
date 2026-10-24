import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/features/auth/data/models/organizer.dart';
import 'package:intl/intl.dart';

class EventSummary {
  final String id;
  final String title;
  final DateTime startsAt;
  final String location;
  final String imageUrl;
  final Organizer organizer;

  /// For example "Concert"; empty if the backend did not send one.
  final String category;

  /// Price of the cheapest ticket, or null when the event has none.
  final double? minPrice;

  const EventSummary({
    required this.id,
    required this.title,
    required this.organizer,
    required this.startsAt,
    required this.location,
    required this.imageUrl,
    this.category = '',
    this.minPrice,
  });

  factory fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'],
      title: json['title'],
      organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>),
      startsAt: DateTime.parse(json['startsAt']),
      location: json['location'],
      imageUrl: json['imageUrl'],
      category: json['category'] as String? ?? '',
      minPrice: (json['minPrice'] as num?)?.toDouble(),
    );
  }

  /// "Free" or "From $25.00"; null when the price is unknown.
  String? get priceLabel {
    final price = minPrice;
    if (price == null) return null;
    return price == 0 ? 'Free' : 'From ${formatMoney(price)}';
  }

  String get time => DateFormat('Hm').format(startsAt);
  String get month => DateFormat('MMM').format(startsAt);
  String get day => DateFormat('dd').format(startsAt);
  String get date => DateFormat('E dd MMM').format(startsAt);
}
