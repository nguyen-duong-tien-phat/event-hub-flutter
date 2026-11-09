import 'package:intl/intl.dart';

/// One person who holds a ticket to an event, and whether they got in.
class EventAdmission {
  const EventAdmission({
    required this.id,
    required this.ticketType,
    required this.shortCode,
    required this.checkedInAt,
    required this.buyerName,
    required this.buyerEmail,
  });

  final String id;
  final String ticketType;
  final String shortCode;
  final DateTime? checkedInAt;
  final String buyerName;
  final String buyerEmail;

  factory EventAdmission.fromJson(Map<String, dynamic> json) {
    final buyer = json['buyer'] as Map<String, dynamic>;
    final at = json['checkedInAt'] as String?;
    return EventAdmission(
      id: json['id'] as String,
      ticketType: json['ticketType'] as String,
      shortCode: json['shortCode'] as String,
      checkedInAt: at == null ? null : DateTime.parse(at).toLocal(),
      buyerName: buyer['fullName'] as String,
      buyerEmail: buyer['email'] as String,
    );
  }

  bool get checkedIn => checkedInAt != null;

  /// "K7Q49XMD" -> "K7Q4 9XMD", easier to read out and to type.
  String get codeLabel => formatShortCode(shortCode);

  /// "7:42 PM"
  String? get checkedInTime =>
      checkedInAt == null ? null : DateFormat('h:mm a').format(checkedInAt!);
}

String formatShortCode(String code) =>
    code.length == 8 ? '${code.substring(0, 4)} ${code.substring(4)}' : code;
