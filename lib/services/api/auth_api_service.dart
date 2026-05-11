import '../../models/user_model.dart';
import 'api_client.dart';

class AuthResult {
  final User user;
  final String token;

  const AuthResult({required this.user, required this.token});
}

class AuthApiService {
  final ApiClient _client;

  AuthApiService(this._client);

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    return _parseAuthResult(data);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final data = await _client.post(
      '/api/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
      },
    );

    return _parseAuthResult(data);
  }

  Future<User> getMe() async {
    final data = await _client.get('/api/auth/me', requiresAuth: true);
    return userFromBackend(data['user'] as Map<String, dynamic>);
  }

  Future<void> saveToken(String token) => _client.saveToken(token);

  Future<void> clearToken() => _client.clearToken();

  AuthResult _parseAuthResult(Map<String, dynamic> data) {
    final token = data['token']?.toString();
    final userJson = data['user'];

    if (token == null || token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const ApiException('Invalid authentication response');
    }

    return AuthResult(
      user: userFromBackend(userJson),
      token: token,
    );
  }
}

User userFromBackend(Map<String, dynamic> json) {
  return User(
    id: _readId(json),
    name: json['name']?.toString() ?? 'User',
    email: json['email']?.toString() ?? '',
    role: _roleFromBackend(json['role']?.toString()),
    phone: json['phone']?.toString(),
    isVerified: json['isVerified'] == true,
    completedTasks: _intFromJson(json['completedTasks']) ?? 0,
    completedRequests: _intFromJson(json['completedRequests']) ?? 0,
    createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
    lastActive: _dateFromJson(json['updatedAt']),
    avgResponseMinutes: _responseMinutes(json['responseTime']),
  );
}

String _readId(Map<String, dynamic> json) {
  return json['id']?.toString() ?? json['_id']?.toString() ?? '';
}

UserRole _roleFromBackend(String? role) {
  return role == 'volunteer' ? UserRole.volunteer : UserRole.requester;
}

DateTime? _dateFromJson(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int? _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

int? _responseMinutes(dynamic value) {
  if (value == null) return null;
  final match = RegExp(r'\d+').firstMatch(value.toString());
  return match == null ? null : int.tryParse(match.group(0)!);
}
