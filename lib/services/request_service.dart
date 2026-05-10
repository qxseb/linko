import '../models/request_model.dart';
import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/request_api_service.dart';
import 'mock_data_service.dart';
import 'storage_service.dart';

class RequestService {
  final StorageService _storage;
  final RequestApiService _requestApi;
  List<Request> _requests = [];

  RequestService(this._storage, this._requestApi);

  Future<void> init() async {
    final stored = _storage.getRequests();
    if (stored.isEmpty) {
      _requests = MockDataService.getMockRequests();
      await _saveRequests();
    } else {
      _requests = stored;
    }

    await refreshRequests();
  }

  Future<void> _saveRequests() async {
    await _storage.saveRequests(_requests);
  }

  List<Request> getAllRequests() => List.unmodifiable(_requests);

  User? getUserById(String userId) => _requestApi.getUserById(userId);

  Future<void> refreshRequests() async {
    try {
      _requests = await _requestApi.getRequests();
      await _saveRequests();
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }
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
        .where(
            (r) => r.status == RequestStatus.open || r.status == RequestStatus.accepted)
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
  }) async {
    try {
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
      );

      _upsertRequest(request);
      await _saveRequests();
      return request;
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }

    await Future.delayed(const Duration(milliseconds: 200));

    final request = Request(
      id: MockDataService.generateId(),
      requesterId: requesterId,
      requesterName: requesterName,
      category: category,
      description: description,
      urgency: urgency,
      location: location,
      preferredTime: preferredTime,
      createdAt: DateTime.now(),
      isProxy: isProxy,
      proxyForName: proxyForName,
      proxyRelationship: proxyRelationship,
      proxyNotes: proxyNotes,
    );

    _requests.insert(0, request);
    await _saveRequests();
    return request;
  }

  Future<Request> acceptRequest(
    String requestId,
    String volunteerId,
    String volunteerName,
  ) async {
    try {
      final request = await _requestApi.acceptRequest(requestId);
      _upsertRequest(request);
      await _saveRequests();
      return request;
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }

    await Future.delayed(const Duration(milliseconds: 200));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request does not exist');

    if (_requests[index].status != RequestStatus.open) {
      throw Exception('Request already accepted by another volunteer');
    }

    final updated = _requests[index].copyWith(
      status: RequestStatus.accepted,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
    );

    _requests[index] = updated;
    await _saveRequests();
    return updated;
  }

  Future<Request> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    try {
      late final Request request;
      if (status == RequestStatus.inProgress) {
        request = await _requestApi.startRequest(requestId);
      } else if (status == RequestStatus.completed) {
        request = await _requestApi.completeRequest(requestId);
      } else if (status == RequestStatus.cancelled) {
        request = await _requestApi.cancelRequest(requestId);
      } else {
        throw const ApiException('Statusul nu poate fi setat direct');
      }

      _upsertRequest(request);
      await _saveRequests();
      return request;
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }

    await Future.delayed(const Duration(milliseconds: 200));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');

    final updated = _requests[index].copyWith(
      status: status,
      completedAt: status == RequestStatus.completed ? DateTime.now() : null,
    );

    _requests[index] = updated;
    await _saveRequests();
    return updated;
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _requestApi.cancelRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
      await _saveRequests();
      return;
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }

    await Future.delayed(const Duration(milliseconds: 200));

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

  bool _canUseLocalFallback(ApiException error) {
    return error.isNetworkError ||
        error.message == 'Trebuie sa fii autentificat';
  }
}
