import '../../models/request_model.dart';
import '../../models/user_model.dart';
import '../../utils/date_time_utils.dart';
import 'api_client.dart';
import 'auth_api_service.dart';

class RequestApiService {
  final ApiClient _client;
  final Map<String, User> _usersById = {};

  RequestApiService(this._client);

  User? getUserById(String id) => _usersById[id];

  Future<List<Request>> getRequests({
    RequestStatus? status,
    RequestUrgency? urgency,
    RequestCategory? category,
  }) async {
    final data = await _client.get(
      '/api/requests',
      query: {
        'status': status == null ? null : _statusToBackend(status),
        'urgency': urgency?.name,
        'category': category == null ? null : _categoryToBackend(category),
      },
    );

    final rawRequests = data['requests'];
    if (rawRequests is! List) {
      throw const ApiException('Request list is invalid');
    }

    return rawRequests.whereType<Map<String, dynamic>>().map((json) {
      _cacheUsers(json);
      return requestFromBackend(json);
    }).toList();
  }

  Future<Request> getRequestById(String id) async {
    final data = await _client.get('/api/requests/$id');
    final requestJson = data['request'] as Map<String, dynamic>;
    _cacheUsers(requestJson);
    return requestFromBackend(requestJson);
  }

  Future<Request> createRequest({
    required RequestCategory category,
    required String description,
    required RequestUrgency urgency,
    required String location,
    required DateTime preferredTime,
    bool isProxy = false,
    String? proxyForName,
    String? proxyRelationship,
    String? proxyNotes,
    double? latitude,
    double? longitude,
  }) async {
    final data = await _client.post(
      '/api/requests',
      requiresAuth: true,
      body: {
        'category': _categoryToBackend(category),
        'title': _titleFor(category, description),
        'description': description,
        'locationText': location,
        'urgency': urgency.name,
        'preferredTime': toBackendIsoString(preferredTime),
        'isProxyRequest': isProxy,
        'proxyName': proxyForName,
        'proxyRelationship': proxyRelationship,
        'proxyNotes': proxyNotes,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final requestJson = data['request'] as Map<String, dynamic>;
    _cacheUsers(requestJson);
    return requestFromBackend(requestJson);
  }

  Future<Request> acceptRequest(String id) async {
    final data = await _client.patch(
      '/api/requests/$id/accept',
      requiresAuth: true,
    );
    final requestJson = data['request'] as Map<String, dynamic>;
    _cacheUsers(requestJson);
    return requestFromBackend(requestJson);
  }

  Future<Request> startRequest(String id) async {
    final data = await _client.patch(
      '/api/requests/$id/start',
      requiresAuth: true,
    );
    final requestJson = data['request'] as Map<String, dynamic>;
    _cacheUsers(requestJson);
    return requestFromBackend(requestJson);
  }

  Future<Request> completeRequest(String id) async {
    final data = await _client.patch(
      '/api/requests/$id/complete',
      requiresAuth: true,
    );
    final requestJson = data['request'] as Map<String, dynamic>;
    _cacheUsers(requestJson);
    return requestFromBackend(requestJson);
  }

  Future<Request> cancelRequest(String id) async {
    final data = await _client.patch(
      '/api/requests/$id/cancel',
      requiresAuth: true,
    );
    final requestJson = data['request'] as Map<String, dynamic>;
    _cacheUsers(requestJson);
    return requestFromBackend(requestJson);
  }

  void _cacheUsers(Map<String, dynamic> requestJson) {
    for (final key in ['requester', 'assignedVolunteer']) {
      final rawUser = requestJson[key];
      if (rawUser is Map<String, dynamic>) {
        final user = userFromBackend(rawUser);
        if (user.id.isNotEmpty) {
          _usersById[user.id] = user;
        }
      }
    }
  }
}

Request requestFromBackend(Map<String, dynamic> json) {
  final requester = _objectOrNull(json['requester']);
  final volunteer = _objectOrNull(json['assignedVolunteer']);
  final status = _statusFromBackend(json['status']?.toString());
  final locationText = json['locationText']?.toString() ?? '';
  final createdAt = _dateFromJson(json['createdAt']) ?? DateTime.now();
  final updatedAt = _dateFromJson(json['updatedAt']);

  return Request(
    id: _readId(json),
    requesterId: _readRelationId(json['requester']),
    requesterName:
        requester == null ? 'Requester' : userFromBackend(requester).name,
    category: _categoryFromBackend(json['category']?.toString()),
    description: json['description']?.toString() ?? '',
    urgency: _urgencyFromBackend(json['urgency']?.toString()),
    location: locationText,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    preferredTime: _dateFromJson(json['preferredTime']) ?? createdAt,
    status: status,
    volunteerId: json['assignedVolunteer'] == null
        ? null
        : _readRelationId(json['assignedVolunteer']),
    volunteerName: volunteer == null ? null : userFromBackend(volunteer).name,
    createdAt: createdAt,
    completedAt: _dateFromJson(json['completedAt']) ??
        (status == RequestStatus.completed ? updatedAt ?? createdAt : null),
    isProxy: json['isProxyRequest'] == true,
    proxyForName: json['proxyName']?.toString(),
    proxyRelationship: json['proxyRelationship']?.toString(),
    proxyNotes: json['proxyNotes']?.toString(),
  );
}

String _readId(Map<String, dynamic> json) {
  return json['id']?.toString() ?? json['_id']?.toString() ?? '';
}

Map<String, dynamic>? _objectOrNull(dynamic value) {
  return value is Map<String, dynamic> ? value : null;
}

String _readRelationId(dynamic value) {
  if (value is Map<String, dynamic>) return _readId(value);
  return value?.toString() ?? '';
}

RequestCategory _categoryFromBackend(String? category) {
  switch (category) {
    case 'pharmacy':
      return RequestCategory.pharmacy;
    case 'errands':
      return RequestCategory.errands;
    case 'checkin':
      return RequestCategory.checkIn;
    default:
      return RequestCategory.groceries;
  }
}

String _categoryToBackend(RequestCategory category) {
  switch (category) {
    case RequestCategory.groceries:
      return 'groceries';
    case RequestCategory.pharmacy:
      return 'pharmacy';
    case RequestCategory.errands:
      return 'errands';
    case RequestCategory.checkIn:
      return 'checkin';
  }
}

RequestUrgency _urgencyFromBackend(String? urgency) {
  switch (urgency) {
    case 'high':
      return RequestUrgency.high;
    case 'low':
      return RequestUrgency.low;
    default:
      return RequestUrgency.medium;
  }
}

RequestStatus _statusFromBackend(String? status) {
  switch (status) {
    case 'accepted':
      return RequestStatus.accepted;
    case 'in_progress':
      return RequestStatus.inProgress;
    case 'completed':
      return RequestStatus.completed;
    case 'cancelled':
      return RequestStatus.cancelled;
    default:
      return RequestStatus.open;
  }
}

String _statusToBackend(RequestStatus status) {
  switch (status) {
    case RequestStatus.open:
      return 'open';
    case RequestStatus.accepted:
      return 'accepted';
    case RequestStatus.inProgress:
      return 'in_progress';
    case RequestStatus.completed:
      return 'completed';
    case RequestStatus.cancelled:
      return 'cancelled';
  }
}

DateTime? _dateFromJson(dynamic value) {
  return parseLocalDateTime(value);
}

String _titleFor(RequestCategory category, String description) {
  final trimmed = description.trim();
  if (trimmed.length <= 42) return trimmed;

  switch (category) {
    case RequestCategory.groceries:
      return 'Groceries';
    case RequestCategory.pharmacy:
      return 'Pharmacy help';
    case RequestCategory.errands:
      return 'Errands';
    case RequestCategory.checkIn:
      return 'Check-in';
  }
}
