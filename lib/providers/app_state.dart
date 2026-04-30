import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/request_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../services/auth_service.dart';
import '../services/request_service.dart';
import '../services/message_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/mock_data_service.dart';

class AppState extends ChangeNotifier {
  late final StorageService _storageService;
  late final AuthService _authService;
  late final RequestService _requestService;
  late final MessageService _messageService;
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppState() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _storageService = StorageService();
    await _storageService.init();
    _authService = AuthService(_storageService);
    _requestService = RequestService(_storageService);
    _messageService = MessageService(_storageService);
    await _authService.init();
    await _requestService.init();
    await _messageService.init();

    _isInitialized = true;
    notifyListeners();
  }

  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> login(String email, String password, UserRole role) async {
    try {
      setLoading(true);
      setError(null);
      await Future.delayed(const Duration(milliseconds: 200));
      await _authService.login(email, password, role);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      setLoading(true);
      setError(null);
      await Future.delayed(const Duration(milliseconds: 200));
      await _authService.register(name, email, password, role);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  List<Request> getAllRequests() => _requestService.getAllRequests();

  List<Request> getMyRequests() {
    if (currentUser == null) return [];
    return _requestService.getRequestsForRequester(currentUser!.id);
  }

  List<Request> getMyVolunteerRequests() {
    if (currentUser == null) return [];
    return _requestService.getRequestsForVolunteer(currentUser!.id);
  }

  List<Request> getAvailableRequests() =>
      _requestService.getAvailableRequests();

  Request? getRequestById(String id) => _requestService.getRequestById(id);

  User? getUserById(String userId) {
    return MockDataService.getUserById(userId);
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
  }) async {
    if (currentUser == null) throw Exception('Nu ești autentificat');

    final request = await _requestService.createRequest(
      requesterId: currentUser!.id,
      requesterName: currentUser!.name,
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

    notifyListeners();
    return request;
  }

  Future<Message> acceptRequest(String requestId) async {
    if (currentUser == null) {
      throw Exception('Nu ești autentificat');
    }

    try {
      setLoading(true);
      setError(null);

      final request = getRequestById(requestId);
      if (request == null) {
        throw Exception('Cererea nu a fost găsită');
      }

      if (request.status != RequestStatus.open) {
        throw Exception('Cererea a fost deja acceptată de alt voluntar');
      }

      await _requestService.acceptRequest(
        requestId,
        currentUser!.id,
        currentUser!.name,
      );

      final initialMessage = await _messageService.addInitialMessage(
        request,
        currentUser!.id,
        currentUser!.name,
      );

      notifyListeners();
      return initialMessage;
    } catch (e) {
      setError('Eroare la acceptarea cererii: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    if (currentUser == null) {
      throw Exception('Nu ești autentificat');
    }

    try {
      setLoading(true);
      setError(null);

      await _requestService.updateRequestStatus(requestId, status);

      if (status == RequestStatus.inProgress) {
        await _messageService.addStatusMessage(requestId, 'inProgress');
      } else if (status == RequestStatus.completed) {
        await _messageService.addStatusMessage(requestId, 'completed');
      }

      notifyListeners();
    } catch (e) {
      setError('Eroare la actualizarea statusului: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> cancelRequest(String requestId) async {
    if (currentUser == null) {
      throw Exception('Nu ești autentificat');
    }

    try {
      setLoading(true);
      setError(null);

      await _requestService.cancelRequest(requestId);
      await _messageService.addStatusMessage(requestId, 'cancelled');

      notifyListeners();
    } catch (e) {
      setError('Eroare la anularea cererii: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  List<Message> getMessages(String requestId) {
    return _messageService.getMessagesForRequest(requestId);
  }

  Future<void> sendMessage(String requestId, String content) async {
    if (currentUser == null) {
      throw Exception('Nu ești autentificat');
    }

    if (content.trim().isEmpty) {
      throw Exception('Mesajul nu poate fi gol');
    }

    try {
      await _messageService.sendMessage(
        requestId: requestId,
        senderId: currentUser!.id,
        senderName: currentUser!.name,
        content: content.trim(),
      );

      notifyListeners();
    } catch (e) {
      throw Exception('Eroare la trimiterea mesajului: ${e.toString()}');
    }
  }

  List<AppNotification> getNotifications() {
    if (currentUser == null) return [];
    return _notificationService.getNotificationsForUser(currentUser!.id);
  }

  int getUnreadNotificationCount() {
    if (currentUser == null) return 0;
    return _notificationService.getUnreadCount(currentUser!.id);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (currentUser == null) return;
    await _notificationService.markAsRead(notificationId, currentUser!.id);
    notifyListeners();
  }

  Map<String, int> getAnalytics() {
    final allRequests = getAllRequests();
    return {
      'totalRequests': allRequests.length,
      'activeRequests': allRequests
          .where(
            (r) =>
                r.status == RequestStatus.open ||
                r.status == RequestStatus.accepted ||
                r.status == RequestStatus.inProgress,
          )
          .length,
      'completedRequests':
          allRequests.where((r) => r.status == RequestStatus.completed).length,
      'activeVolunteers': allRequests
          .where((r) => r.volunteerId != null)
          .map((r) => r.volunteerId)
          .toSet()
          .length,
    };
  }
}
