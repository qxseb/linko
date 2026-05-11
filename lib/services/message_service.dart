import '../models/message_model.dart';
import '../models/request_model.dart';
import 'api/message_api_service.dart';
import 'storage_service.dart';

class MessageService {
  final StorageService _storage;
  final MessageApiService _messageApi;
  final bool _demoMode;
  final Map<String, List<Message>> _demoInitialMessages;
  final Map<String, List<Message>> _messagesByRequest = {};

  MessageService(
    this._storage,
    this._messageApi, {
    bool demoMode = false,
    Map<String, List<Message>> demoInitialMessages = const {},
  })  : _demoMode = demoMode,
        _demoInitialMessages = demoInitialMessages;

  Future<void> init() async {}

  bool hasCachedMessages(String requestId) {
    return _messagesByRequest.containsKey(requestId);
  }

  List<Message> getMessagesForRequest(String requestId) {
    if (!_messagesByRequest.containsKey(requestId)) {
      final storedMessages = _storage.getMessages(requestId);
      _messagesByRequest[requestId] =
          storedMessages.isNotEmpty ? storedMessages : [];
    }
    return List.unmodifiable(_messagesByRequest[requestId]!);
  }

  Future<List<Message>> loadMessagesForRequest(String requestId) async {
    if (_demoMode) {
      final stored = _storage.getMessages(requestId);
      if (stored.isNotEmpty) {
        _messagesByRequest[requestId] = stored;
        return List.unmodifiable(stored);
      }

      final seeded = _demoInitialMessages[requestId] ?? const <Message>[];
      _messagesByRequest[requestId] = List<Message>.from(seeded);
      if (seeded.isNotEmpty) {
        await _storage.saveMessages(requestId, seeded);
      }
      return List.unmodifiable(_messagesByRequest[requestId]!);
    }

    final messages = await _messageApi.getMessages(requestId);
    _messagesByRequest[requestId] = messages;
    await _storage.saveMessages(requestId, messages);
    return List.unmodifiable(messages);
  }

  Future<Message> sendMessage({
    required String requestId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    if (_demoMode) {
      final message = Message(
        id: 'demo_msg_${DateTime.now().millisecondsSinceEpoch}',
        requestId: requestId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        timestamp: DateTime.now(),
        isRead: true,
      );
      _messagesByRequest.putIfAbsent(requestId, () => []);
      _messagesByRequest[requestId]!.add(message);
      await _storage.saveMessages(requestId, _messagesByRequest[requestId]!);
      return message;
    }

    final message = await _messageApi.sendMessage(
      requestId: requestId,
      text: content,
    );
    _messagesByRequest.putIfAbsent(requestId, () => []);
    _messagesByRequest[requestId]!.add(message);
    await _storage.saveMessages(requestId, _messagesByRequest[requestId]!);
    return message;
  }

  Future<void> addInitialMessage(
    Request request,
    String volunteerId,
    String volunteerName,
  ) async {
    await loadMessagesForRequest(request.id);
  }

  Future<void> addStatusMessage(String requestId, String status) async {
    await loadMessagesForRequest(requestId);
  }
}
