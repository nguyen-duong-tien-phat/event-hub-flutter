import 'package:dio/dio.dart';
import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/core/network/token_storage.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'] as String;
      final user = User.fromJson(response.data);

      await _tokenStorage.saveToken(token);
      return user;
    } on DioException catch (e) {
      throw AuthException(_extractErrorMessage(e));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _apiClient.dio.post(
        'auth/register',
        data: {'email': email, 'password': password, 'fullName': fullName},
      );
    } on DioException catch (e) {
      throw AuthException(_extractErrorMessage(e));
    }
  }

  Future<User?> getMe() async {
    try {
      final response = await _apiClient.dio.get('auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Could not reach the server. Check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'No connection to the server.';
      default:
        if (e.response?.statusCode == 401) {
          return 'Incorrect email or password.';
        }
        return 'Something went wrong. Please try again.';
    }
  }
}
