import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/auth_api_service.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage;
  final AuthApiService _authApi;
  User? _currentUser;

  AuthService(this._storage, this._authApi);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    _currentUser = _storage.getCurrentUser();

    if (_currentUser == null) return;

    await refreshCurrentUser();
  }

  Future<bool> refreshCurrentUser() async {
    if (_currentUser == null) return false;

    try {
      _currentUser = await _authApi.getMe();
      await _storage.saveCurrentUser(_currentUser!);
      return true;
    } on ApiException catch (e) {
      if (!e.isNetworkError) {
        _currentUser = null;
        await _storage.clearCurrentUser();
        await _authApi.clearToken();
      }
      return false;
    }
  }

  Future<User> login(String email, String password, UserRole role) async {
    final result = await _authApi.login(
      email: email.trim().toLowerCase(),
      password: password,
    );

    if (result.user.role != role) {
      throw const ApiException('The selected role does not match this account');
    }

    await _authApi.saveToken(result.token);
    _currentUser = result.user;
    await _storage.saveCurrentUser(_currentUser!);
    return _currentUser!;
  }

  Future<User> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    final result = await _authApi.register(
      name: name,
      email: email.trim().toLowerCase(),
      password: password,
      role: role,
    );

    await _authApi.saveToken(result.token);
    _currentUser = result.user;
    await _storage.saveCurrentUser(_currentUser!);
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
    await _storage.clearCurrentUser();
    await _authApi.clearToken();
  }

  Future<void> setUser(User user) async {
    _currentUser = user;
    await _storage.saveCurrentUser(user);
  }

}
