import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/network/token_storage.dart';
import 'package:event_hub_mobile/features/auth/data/auth_repository.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    final token = await ref.read(tokenProvider).read();
    if (token == null) return null;

    try {
      return await ref.read(authRepositoryProvider).me();
    } on UnauthorizedException {
      await ref.read(tokenProvider).clear();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final user = await ref.read(authRepositoryProvider).login(email, password);
    state = AsyncData(user);
  }

  Future<void> register(String fullName, String email, String password) {
    return ref.read(authRepositoryProvider).register(fullName, email, password);
  }

  /// The server refused the session (the refresh token is gone or expired).
  /// Unlike [logout] it does not call the server: that call would fail the same
  /// way, and it is made from inside the request that found out.
  Future<void> sessionEnded() async {
    await ref.read(tokenProvider).clear();
    state = const AsyncData(null);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
