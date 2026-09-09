import 'package:event_hub_mobile/core/network/token_storage.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthProvider({AuthRepository? authRepository, TokenStorage? tokenStorage})
    : _authRepository = authRepository ?? AuthRepository(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  User? _currentUser;
  User? get user => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  Future<void> tryAutoLogin() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        return;
      }

      final user = await _authRepository.getMe();

      debugPrint('user $user');

      if (user != null) {
        _currentUser = user;
      }
    } catch (e) {
      debugPrint('Auto login failed: $e');
      _currentUser = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final user = await _authRepository.login(email: email, password: password);

    await _tokenStorage.saveUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _authRepository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clearAll();
    _currentUser = null;
    notifyListeners();
  }
}
