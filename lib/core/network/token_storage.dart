import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage.g.dart';

class TokenStorage {
  static const String _accessTokenKey = 'jwt-accesstoken';
  static const String _refreshTokenKey = 'jwt-refreshtoken';
  final storage = const FlutterSecureStorage();

  Future<String?> read() {
    return storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefresh() {
    return storage.read(key: _refreshTokenKey);
  }

  /// A refresh token works once, so the new pair always replaces the old one.
  Future<void> save(String accessToken, String refreshToken) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }
}

@Riverpod(keepAlive: true)
TokenStorage token(Ref ref) {
  return TokenStorage();
}
