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
}
