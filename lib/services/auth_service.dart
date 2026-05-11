import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/auth_api_service.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage;
  final AuthApiService _authApi;
  final bool _demoMode;
  final Map<String, User> _demoUsersByEmail;
  User? _currentUser;

  AuthService(
    this._storage,
    this._authApi, {
    bool demoMode = false,
    List<User> demoUsers = const [],
  })  : _demoMode = demoMode,
        _demoUsersByEmail = {
          for (final user in demoUsers) user.email.toLowerCase(): user,
        };

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    _currentUser = _storage.getCurrentUser();

    if (_currentUser == null) return;

    if (_demoMode) return;

    await refreshCurrentUser();
  }

  Future<bool> refreshCurrentUser() async {
    if (_currentUser == null) return false;
    if (_demoMode) return true;

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
    if (_demoMode) {
      final user = _demoUsersByEmail[email.trim().toLowerCase()];
      if (user == null) {
        throw const ApiException(
          'Demo account not found. Try maria.ionescu@demo.linko or ioana.stan@demo.linko',
        );
      }
      if (user.role != role) {
        throw const ApiException('The selected role does not match this account');
      }
      if (password.trim().isEmpty) {
        throw const ApiException('Password is required');
      }

      _currentUser = user;
      await _storage.saveCurrentUser(_currentUser!);
      await _authApi.saveToken('demo-mode-token');
      return _currentUser!;
    }

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
    if (_demoMode) {
      if (password.length < 6) {
        throw const ApiException('Password must be at least 6 characters');
      }
      final now = DateTime.now();
      _currentUser = User(
        id: 'demo_local_${now.millisecondsSinceEpoch}',
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        createdAt: now,
        lastActive: now,
        isVerified: true,
      );
      await _storage.saveCurrentUser(_currentUser!);
      await _authApi.saveToken('demo-mode-token');
      return _currentUser!;
    }

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
