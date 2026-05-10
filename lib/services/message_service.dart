import '../models/message_model.dart';
import '../models/request_model.dart';
import 'api/api_client.dart';
import 'api/message_api_service.dart';
import 'mock_data_service.dart';
import 'storage_service.dart';

class MessageService {
  final StorageService _storage;
  final MessageApiService _messageApi;
  final Map<String, List<Message>> _messagesByRequest = {};

  MessageService(this._storage, this._messageApi);

  Future<void> init() async {}

  bool hasCachedMessages(String requestId) {
    return _messagesByRequest.containsKey(requestId);
  }

  List<Message> getMessagesForRequest(String requestId) {
    if (!_messagesByRequest.containsKey(requestId)) {
      final storedMessages = _storage.getMessages(requestId);
      if (storedMessages.isNotEmpty) {
        _messagesByRequest[requestId] = storedMessages;
      } else {
        _messagesByRequest[requestId] = MockDataService.getMockMessages(
          requestId,
        );
      }
    }
    return List.unmodifiable(_messagesByRequest[requestId]!);
  }

  Future<List<Message>> loadMessagesForRequest(String requestId) async {
    try {
      final messages = await _messageApi.getMessages(requestId);
      _messagesByRequest[requestId] = messages;
      await _storage.saveMessages(requestId, messages);
      return List.unmodifiable(messages);
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
      return getMessagesForRequest(requestId);
    }
  }

  Future<Message> sendMessage({
    required String requestId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      final message = await _messageApi.sendMessage(
        requestId: requestId,
        text: content,
      );

      _messagesByRequest.putIfAbsent(requestId, () => []);
      _messagesByRequest[requestId]!.add(message);
      await _storage.saveMessages(requestId, _messagesByRequest[requestId]!);
      return message;
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }

    await Future.delayed(const Duration(milliseconds: 150));

    final message = Message(
      id: MockDataService.generateId(),
      requestId: requestId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
    );

    if (!_messagesByRequest.containsKey(requestId)) {
      _messagesByRequest[requestId] = [];
    }
    _messagesByRequest[requestId]!.add(message);

    await _storage.saveMessages(requestId, _messagesByRequest[requestId]!);

    return message;
  }

  Future<Message> addInitialMessage(
    Request request,
    String volunteerId,
    String volunteerName,
  ) async {
    try {
      final messages = await loadMessagesForRequest(request.id);
      final requesterMessages = messages
          .where((message) =>
              !message.isSystemMessage && message.senderId != volunteerId)
          .toList();
      if (requesterMessages.isNotEmpty) {
        return requesterMessages.last;
      }
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }

    if (!_messagesByRequest.containsKey(request.id)) {
      _messagesByRequest[request.id] = [];
    }

    final systemMessage = MockDataService.generateSystemMessage(
      request.id,
      'request_accepted',
    );
    _messagesByRequest[request.id]!.add(systemMessage);

    await Future.delayed(const Duration(milliseconds: 100));
    final requesterMessage = MockDataService.generateRequesterResponseMessage(
      request,
      volunteerId,
      volunteerName,
    );
    _messagesByRequest[request.id]!.add(requesterMessage);

    await Future.delayed(const Duration(milliseconds: 500));
    final volunteerMessage = MockDataService.generateInitialMessage(
      request,
      volunteerId,
      volunteerName,
    );
    _messagesByRequest[request.id]!.add(volunteerMessage);

    await _storage.saveMessages(request.id, _messagesByRequest[request.id]!);

    return requesterMessage;
  }

  Future<void> addStatusMessage(String requestId, String status) async {
    try {
      await loadMessagesForRequest(requestId);
      return;
    } on ApiException catch (e) {
      if (!_canUseLocalFallback(e)) rethrow;
    }

    String content;
    switch (status) {
      case 'inProgress':
        content = 'request_in_progress';
        break;
      case 'completed':
        content = 'request_completed';
        break;
      case 'cancelled':
        content = 'request_cancelled';
        break;
      default:
        content = 'Status actualizat';
    }

    if (!_messagesByRequest.containsKey(requestId)) {
      _messagesByRequest[requestId] = MockDataService.getMockMessages(
        requestId,
      );
    }

    final systemMessage = MockDataService.generateSystemMessage(
      requestId,
      content,
    );

    _messagesByRequest[requestId]!.add(systemMessage);

    await _storage.saveMessages(requestId, _messagesByRequest[requestId]!);
  }

  bool _canUseLocalFallback(ApiException error) {
    return error.isNetworkError ||
        error.message == 'Trebuie sa fii autentificat';
  }
}
