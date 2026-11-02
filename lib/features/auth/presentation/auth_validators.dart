String? validateRequired(String? value, String message) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter a password';
  if (value.length < 6) return 'At least 6 characters';
  return null;
}

/// The code from the reset email: exactly six digits.
String? validateResetCode(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Enter the code from the email';
  if (!RegExp(r'^\d{6}$').hasMatch(code)) return 'The code is 6 digits';
  return null;
}

/// A password chosen while resetting. The server asks for 8 characters.
String? validateResetPassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter a new password';
  if (value.length < 8) return 'At least 8 characters';
  return null;
}
