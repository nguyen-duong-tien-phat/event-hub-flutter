class Organizer {
  final String id;
  final String fullName;

  const Organizer({required this.id, required this.fullName});

  factory fromJson(Map<String, dynamic> json) {
    return Organizer(id: json['id'], fullName: json['fullName']);
  }
}
