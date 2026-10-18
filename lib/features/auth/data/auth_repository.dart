import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/core/network/network_provider.dart';
import 'package:event_hub_mobile/core/network/token_storage.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<User> login(String email, String password) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      parser: (json) => json as Map<String, dynamic>,
    );

    await _tokenStorage.save(response['token'] as String);
    return User.fromJson(response);
  }

  Future<void> register(String fullName, String email, String password) {
    return _apiClient.post<void>(
      '/auth/register',
      data: {'fullName': fullName, 'email': email, 'password': password},
      parser: (_) {},
    );
  }

  Future<User> me() {
    return _apiClient.get(
      '/auth/me',
      parser: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> logout() => _tokenStorage.clear();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenProvider));
}
