import 'package:event_hub_mobile/core/network/base_repository.dart';
import 'package:event_hub_mobile/core/network/token_storage.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';

class AuthRepository extends BaseRepository {
  final TokenStorage _tokenStorage;

  AuthRepository({super.apiClient, TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? TokenStorage();

  Future<User> login({required String email, required String password}) {
    return handleRequest(() async {
      final response = await apiClient.dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'] as String;
      final user = User.fromJson(response.data);

      await _tokenStorage.saveToken(token);

      return user;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) {
    return handleRequest(() async {
      await apiClient.dio.post(
        'auth/register',
        data: {'email': email, 'password': password, 'fullName': fullName},
      );
    });
  }

  Future<User?> getMe() {
    return handleRequest(() async {
      final response = await apiClient.dio.get('auth/me');
      return User.fromJson(response.data);
    });
  }
}
