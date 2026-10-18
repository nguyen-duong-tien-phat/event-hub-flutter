import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage.g.dart';

class TokenStorage {
  static const String _accessTokenKey = 'jwt-accesstoken';
  final storage = const FlutterSecureStorage();

  Future<String?> read() {
    return storage.read(key: _accessTokenKey);
  }

  Future<void> save(String token) async {
    await storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clear() async {
    await storage.delete(key: _accessTokenKey);
  }
}

@Riverpod(keepAlive: true)
TokenStorage token(Ref ref) {
  return TokenStorage();
}
