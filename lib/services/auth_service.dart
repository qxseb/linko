import '../models/user_model.dart';
import 'mock_data_service.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage;
  User? _currentUser;

  AuthService(this._storage);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    _currentUser = _storage.getCurrentUser();
  }

  Future<User> login(String email, String password, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _currentUser = role == UserRole.requester
        ? MockDataService.createMockRequester()
        : MockDataService.createMockVolunteer();

    await _storage.saveCurrentUser(_currentUser!);
    return _currentUser!;
  }

  Future<User> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _currentUser = User(
      id: MockDataService.generateId(),
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    await _storage.saveCurrentUser(_currentUser!);
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
    await _storage.clearCurrentUser();
  }

  void setUser(User user) {
    _currentUser = user;
  }
}
