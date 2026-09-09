import 'dart:convert';

import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps secure storage for the JWT — keeps the actual storage
/// mechanism (Keychain on iOS) out of the rest of the app, so if you
/// ever swap how tokens are stored, only this file changes.
class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_token';
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<void> saveUser(User user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  Future<User?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearUser() => _storage.delete(key: _userKey);

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}
