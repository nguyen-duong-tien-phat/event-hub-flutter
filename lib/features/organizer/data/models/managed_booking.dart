import 'package:intl/intl.dart';

enum ManagedBookingStatus { pending, confirmed, cancelled }

/// A booking on one of the organizer's events, with who made it. Read only.
class ManagedBooking {
  const ManagedBooking({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventImageUrl,
    required this.itemsLabel,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.buyerName,
  });

  final String id;
  final String eventId;
  final String eventTitle;
  final String eventImageUrl;

  /// "2 × VIP, 1 × General"
  final String itemsLabel;
  final double totalPrice;
  final ManagedBookingStatus status;
  final DateTime createdAt;
  final String buyerName;

  factory ManagedBooking.fromJson(Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>?;
    final buyer = json['buyer'] as Map<String, dynamic>?;
    final tickets = (json['tickets'] as List)
        .map((t) => '${t['quantity']} × ${t['type']}')
        .join(', ');
    final statusName = (json['status'] as String).toLowerCase();
    return ManagedBooking(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      eventTitle: event?['title'] as String? ?? '',
      eventImageUrl: event?['imageUrl'] as String? ?? '',
      itemsLabel: tickets,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: ManagedBookingStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => ManagedBookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      buyerName: buyer?['fullName'] as String? ?? 'Unknown',
    );
  }

  /// "Today, 2:14 PM", "Yesterday", or "Mon, Oct 9".
  String get whenLabel {
    final now = DateTime.now();
    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(day).inDays;
    if (days == 0) return 'Today, ${DateFormat('h:mm a').format(createdAt)}';
    if (days == 1) return 'Yesterday';
    return DateFormat('E, MMM d').format(createdAt);
  }
}
