import '../models/request_model.dart';
import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/request_api_service.dart';
import 'storage_service.dart';

class RequestService {
  final StorageService _storage;
  final RequestApiService _requestApi;
  final bool _demoMode;
  final Map<String, User> _demoUsersById;
  final List<Request> _demoInitialRequests;
  List<Request> _requests = [];

  RequestService(
    this._storage,
    this._requestApi, {
    bool demoMode = false,
    Map<String, User> demoUsersById = const {},
    List<Request> demoInitialRequests = const [],
  })  : _demoMode = demoMode,
        _demoUsersById = demoUsersById,
        _demoInitialRequests = demoInitialRequests;

  Future<void> init() async {
    _requests = _storage.getRequests();
    if (_demoMode) {
      await _seedDemoRequestsIfNeeded();
      return;
    }
    await refreshRequests();
  }

  Future<void> _saveRequests() async {
    await _storage.saveRequests(_requests);
  }

  List<Request> getAllRequests() => List.unmodifiable(_requests);

  User? getUserById(String userId) {
    if (_demoMode) return _demoUsersById[userId];
    return _requestApi.getUserById(userId);
  }

  Future<void> refreshRequests() async {
    if (_demoMode) {
      _requests = _storage.getRequests();
      await _seedDemoRequestsIfNeeded();
      return;
    }
    _requests = await _requestApi.getRequests();
    await _saveRequests();
  }

  List<Request> getRequestsByStatus(RequestStatus status) {
    return _requests.where((r) => r.status == status).toList();
  }

  List<Request> getRequestsForRequester(String requesterId) {
    return _requests.where((r) => r.requesterId == requesterId).toList();
  }

  List<Request> getRequestsForVolunteer(String volunteerId) {
    return _requests
        .where((r) =>
            r.volunteerId == volunteerId &&
            r.status != RequestStatus.cancelled &&
            r.status != RequestStatus.completed)
        .toList();
  }

  List<Request> getAvailableRequests() {
    final available = _requests
        .where((r) => r.status == RequestStatus.open)
        .toList();
    available.sort((a, b) {
      if (a.urgency != b.urgency) {
        return b.urgency.index.compareTo(a.urgency.index);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return available;
  }

  Request? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Request> createRequest({
    required String requesterId,
    required String requesterName,
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
    if (_demoMode) {
      final request = Request(
        id: 'demo_req_${DateTime.now().millisecondsSinceEpoch}',
        requesterId: requesterId,
        requesterName: requesterName,
        category: category,
        description: description,
        urgency: urgency,
        location: location,
        preferredTime: preferredTime,
        isProxy: isProxy,
        proxyForName: proxyForName,
        proxyRelationship: proxyRelationship,
        proxyNotes: proxyNotes,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );
      _upsertRequest(request);
      await _saveRequests();
      return request;
    }

    final request = await _requestApi.createRequest(
      category: category,
      description: description,
      urgency: urgency,
      location: location,
      preferredTime: preferredTime,
      isProxy: isProxy,
      proxyForName: proxyForName,
      proxyRelationship: proxyRelationship,
      proxyNotes: proxyNotes,
      latitude: latitude,
      longitude: longitude,
    );
    _upsertRequest(request);
    await _saveRequests();
    return request;
  }

  Future<Request> acceptRequest(
    String requestId,
    String volunteerId,
    String volunteerName,
  ) async {
    if (_demoMode) {
      final existing = getRequestById(requestId);
      if (existing == null) {
        throw const ApiException('Request not found');
      }
      final request = existing.copyWith(
        status: RequestStatus.accepted,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
      );
      _upsertRequest(request);
      await _saveRequests();
      return request;
    }

    final request = await _requestApi.acceptRequest(requestId);
    _upsertRequest(request);
    await _saveRequests();
    return request;
  }

  Future<Request> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    if (_demoMode) {
      final existing = getRequestById(requestId);
      if (existing == null) {
        throw const ApiException('Request not found');
      }

      final request = existing.copyWith(
        status: status,
        completedAt:
            status == RequestStatus.completed ? DateTime.now() : null,
      );
      _upsertRequest(request);
      await _saveRequests();
      return request;
    }

    late final Request request;
    if (status == RequestStatus.inProgress) {
      request = await _requestApi.startRequest(requestId);
    } else if (status == RequestStatus.completed) {
      request = await _requestApi.completeRequest(requestId);
    } else if (status == RequestStatus.cancelled) {
      request = await _requestApi.cancelRequest(requestId);
    } else {
      throw const ApiException('Status cannot be set directly');
    }
    _upsertRequest(request);
    await _saveRequests();
    return request;
  }

  Future<void> cancelRequest(String requestId) async {
    if (_demoMode) {
      _requests.removeWhere((r) => r.id == requestId);
      await _saveRequests();
      return;
    }

    await _requestApi.cancelRequest(requestId);
    _requests.removeWhere((r) => r.id == requestId);
    await _saveRequests();
  }

  void _upsertRequest(Request request) {
    final index = _requests.indexWhere((r) => r.id == request.id);
    if (index == -1) {
      _requests.insert(0, request);
    } else if (request.status != RequestStatus.cancelled &&
        request.status != RequestStatus.completed) {
      _requests[index] = request;
    } else {
      _requests.removeAt(index);
    }
  }

  Future<void> _seedDemoRequestsIfNeeded() async {
    if (_requests.isNotEmpty || _demoInitialRequests.isEmpty) return;
    _requests = List<Request>.from(_demoInitialRequests);
    await _saveRequests();
  }
}
