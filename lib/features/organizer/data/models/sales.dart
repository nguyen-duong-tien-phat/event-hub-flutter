import 'package:intl/intl.dart';

/// Totals over the events the organizer owns (an admin: everyone's).
class SalesSummary {
  const SalesSummary({
    required this.events,
    required this.upcoming,
    required this.past,
    required this.ticketsSold,
    required this.ticketRevenue,
    required this.checkedIn,
    required this.ticketsSoldOfPastEvents,
  });

  final int events;
  final int upcoming;
  final int past;
  final int ticketsSold;

  /// Paid for the tickets, without the service fee.
  final double ticketRevenue;
  final int checkedIn;

  /// Tickets sold for events that have already started: what a check-in
  /// count can be compared with.
  final int ticketsSoldOfPastEvents;

  factory SalesSummary.fromJson(Map<String, dynamic> json) => SalesSummary(
    events: json['events'] as int,
    upcoming: json['upcoming'] as int,
    past: json['past'] as int,
    ticketsSold: json['ticketsSold'] as int,
    ticketRevenue: (json['ticketRevenue'] as num).toDouble(),
    checkedIn: json['checkedIn'] as int,
    ticketsSoldOfPastEvents: json['ticketsSoldOfPastEvents'] as int,
  );

  /// Share (0 to 1) of the tickets of past events that were scanned, or null
  /// when no past event sold anything.
  double? get attendanceRate => ticketsSoldOfPastEvents == 0
      ? null
      : (checkedIn / ticketsSoldOfPastEvents).clamp(0, 1).toDouble();
}

/// One event's line in the sales list.
class EventSales {
  const EventSales({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.location,
    required this.imageUrl,
    required this.category,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.ticketsSold,
    required this.ticketRevenue,
    required this.checkedIn,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String location;
  final String imageUrl;
  final String category;
  final int totalQuantity;
  final int remainingQuantity;
  final int ticketsSold;
  final double ticketRevenue;
  final int checkedIn;

  factory EventSales.fromJson(Map<String, dynamic> json) => EventSales(
    id: json['id'] as String,
    title: json['title'] as String,
    startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
    location: json['location'] as String,
    imageUrl: json['imageUrl'] as String? ?? '',
    category: json['category'] as String? ?? '',
    totalQuantity: json['totalQuantity'] as int,
    remainingQuantity: json['remainingQuantity'] as int,
    ticketsSold: json['ticketsSold'] as int,
    ticketRevenue: (json['ticketRevenue'] as num).toDouble(),
    checkedIn: json['checkedIn'] as int,
  );

  bool get isUpcoming => startsAt.isAfter(DateTime.now());

  /// 0 to 1: how much of the stock is sold.
  double get soldFraction => totalQuantity == 0
      ? 0
      : (ticketsSold / totalQuantity).clamp(0, 1).toDouble();

  String get month => DateFormat('MMM').format(startsAt).toUpperCase();
  String get day => DateFormat('dd').format(startsAt);

  /// "Sat · 7:00 PM"
  String get when => DateFormat('E · h:mm a').format(startsAt);
}

class Sales {
  const Sales({required this.summary, required this.events});

  final SalesSummary summary;
  final List<EventSales> events;

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
    summary: SalesSummary.fromJson(json['summary'] as Map<String, dynamic>),
    events: ((json['events'] as Map<String, dynamic>)['items'] as List)
        .map((e) => EventSales.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  List<EventSales> get upcoming => [
    for (final e in events)
      if (e.isUpcoming) e,
  ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  List<EventSales> get past => [
    for (final e in events)
      if (!e.isUpcoming) e,
  ]; // the backend sends the newest first
}
