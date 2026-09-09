enum UserRole { admin, attendee, organizer }

class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['fullName'],
      role: _roleFromJson(json['role']),
    );
  }

  static UserRole _roleFromJson(dynamic value) {
    if (value is int) {
      return UserRole.values[value];
    }
    final normalized = value.toString().toLowerCase();
    return UserRole.values.firstWhere(
      (r) => r.name == normalized,
      orElse: () => UserRole.attendee,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'role': role.name,
  };
}
