import '../models/request_model.dart';
import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/request_api_service.dart';
import 'storage_service.dart';

class RequestService {
  final StorageService _storage;
  final RequestApiService _requestApi;
  List<Request> _requests = [];

  RequestService(this._storage, this._requestApi);

  Future<void> init() async {
    _requests = _storage.getRequests();
    await refreshRequests();
  }

  Future<void> _saveRequests() async {
    await _storage.saveRequests(_requests);
  }

  List<Request> getAllRequests() => List.unmodifiable(_requests);

  User? getUserById(String userId) => _requestApi.getUserById(userId);

  Future<void> refreshRequests() async {
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
    final request = await _requestApi.acceptRequest(requestId);
    _upsertRequest(request);
    await _saveRequests();
    return request;
  }

  Future<Request> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
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
}
