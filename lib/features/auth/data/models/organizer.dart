class Organizer {
  final String id;
  final String fullName;

  /// Contact email. The backend only sends it with the event detail.
  final String? email;

  const Organizer({required this.id, required this.fullName, this.email});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'] as String?,
    );
  }
}
