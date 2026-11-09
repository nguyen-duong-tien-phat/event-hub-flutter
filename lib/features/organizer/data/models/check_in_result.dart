import 'package:event_hub_mobile/features/organizer/data/models/event_admission.dart';
import 'package:intl/intl.dart';

enum CheckInStatus {
  admitted,

  /// The ticket was scanned before.
  alreadyUsed,

  /// The booking behind the ticket is not paid.
  notPaid,

  /// Not one of our codes.
  invalid,

  /// A real ticket, but for an event that is not the scanner's.
  forbidden,
}

/// What the API answered to a scan: what to show the person at the door.
class CheckInResult {
  const CheckInResult({
    required this.status,
    this.eventTitle,
    this.ticketType,
    this.shortCode,
    this.checkedInAt,
  });

  final CheckInStatus status;
  final String? eventTitle;
  final String? ticketType;
  final String? shortCode;

  /// When the ticket got in: now for admitted, the first scan for already used.
  final DateTime? checkedInAt;

  factory CheckInResult.fromJson(Map<String, dynamic> json) {
    final name = (json['status'] as String?)?.toLowerCase();
    final at = json['checkedInAt'] as String?;
    return CheckInResult(
      status: CheckInStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == name,
        orElse: () => CheckInStatus.invalid,
      ),
      eventTitle: json['eventTitle'] as String?,
      ticketType: json['ticketType'] as String?,
      shortCode: json['shortCode'] as String?,
      checkedInAt: at == null ? null : DateTime.parse(at).toLocal(),
    );
  }

  String? get codeLabel =>
      shortCode == null ? null : formatShortCode(shortCode!);

  String? get timeLabel =>
      checkedInAt == null ? null : DateFormat('h:mm a').format(checkedInAt!);
}
