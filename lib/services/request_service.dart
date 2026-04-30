import '../models/request_model.dart';
import 'mock_data_service.dart';
import 'storage_service.dart';

class RequestService {
  final StorageService _storage;
  List<Request> _requests = [];

  RequestService(this._storage);

  Future<void> init() async {
    final stored = _storage.getRequests();
    if (stored.isEmpty) {
      _requests = MockDataService.getMockRequests();
      await _saveRequests();
    } else {
      _requests = stored;
    }
  }

  Future<void> _saveRequests() async {
    await _storage.saveRequests(_requests);
  }

  List<Request> getAllRequests() => List.unmodifiable(_requests);

  List<Request> getRequestsByStatus(RequestStatus status) {
    return _requests.where((r) => r.status == status).toList();
  }

  List<Request> getRequestsForRequester(String requesterId) {
    return _requests.where((r) => r.requesterId == requesterId).toList();
  }

  List<Request> getRequestsForVolunteer(String volunteerId) {
    return _requests.where((r) => r.volunteerId == volunteerId).toList();
  }

  List<Request> getAvailableRequests() {
    final available =
        _requests.where((r) => r.status == RequestStatus.open).toList();
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
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Cererea nu există');

    if (_requests[index].status != RequestStatus.open) {
      throw Exception('Cererea a fost deja acceptată de alt voluntar');
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
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Cerere negăsită');

    final updated = _requests[index].copyWith(
      status: status,
      completedAt: status == RequestStatus.completed ? DateTime.now() : null,
    );

    _requests[index] = updated;
    await _saveRequests();
    return updated;
  }

  Future<void> cancelRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Cerere negăsită');

    _requests[index] =
        _requests[index].copyWith(status: RequestStatus.cancelled);
    await _saveRequests();
  }
}
