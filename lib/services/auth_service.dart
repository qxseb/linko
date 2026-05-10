import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/auth_api_service.dart';
import 'mock_data_service.dart';
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
    try {
      final result = await _authApi.login(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (result.user.role != role) {
        throw const ApiException('Rolul selectat nu corespunde contului');
      }

      await _authApi.saveToken(result.token);
      _currentUser = result.user;
    } on ApiException catch (e) {
      if (!e.isNetworkError) {
        throw Exception(e.message);
      }
      _currentUser = await _offlineDemoLogin(email, role);
    }

    await _storage.saveCurrentUser(_currentUser!);
    return _currentUser!;
  }

  Future<User> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      final result = await _authApi.register(
        name: name,
        email: email.trim().toLowerCase(),
        password: password,
        role: role,
      );

      await _authApi.saveToken(result.token);
      _currentUser = result.user;
    } on ApiException catch (e) {
      if (!e.isNetworkError) {
        throw Exception(e.message);
      }

      _currentUser = User(
        id: MockDataService.generateId(),
        name: name,
        email: email.trim().toLowerCase(),
        role: role,
        isVerified: true,
        createdAt: DateTime.now(),
      );
    }

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

  Future<User> _offlineDemoLogin(String email, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final normalizedEmail = email.trim().toLowerCase();
    final isDemoEmail = normalizedEmail == 'maria.popescu@email.com' ||
        normalizedEmail == 'andrei.ionescu@email.com' ||
        normalizedEmail.endsWith('@demo.linko');

    if (!isDemoEmail) {
      throw Exception(
        'Serverul nu este disponibil. Pentru modul demo foloseste un cont demo.',
      );
    }

    return role == UserRole.requester
        ? MockDataService.createMockRequester()
        : MockDataService.createMockVolunteer();
  }
}
