import '../models/message_model.dart';
import '../models/request_model.dart';
import 'api/message_api_service.dart';
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
      _messagesByRequest[requestId] =
          storedMessages.isNotEmpty ? storedMessages : [];
    }
    return List.unmodifiable(_messagesByRequest[requestId]!);
  }

  Future<List<Message>> loadMessagesForRequest(String requestId) async {
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
