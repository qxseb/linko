import '../../models/message_model.dart';
import 'api_client.dart';
import 'auth_api_service.dart';

class MessageApiService {
  final ApiClient _client;

  MessageApiService(this._client);

  Future<List<Message>> getMessages(String requestId) async {
    final data = await _client.get(
      '/api/requests/$requestId/messages',
      requiresAuth: true,
    );

    final rawMessages = data['messages'];
    if (rawMessages is! List) {
      throw const ApiException('Message list is invalid');
    }

    return rawMessages
        .whereType<Map<String, dynamic>>()
        .map((json) => messageFromBackend(json, requestId))
        .toList();
  }

  Future<Message> sendMessage({
    required String requestId,
    required String text,
  }) async {
    final data = await _client.post(
      '/api/requests/$requestId/messages',
      requiresAuth: true,
      body: {'text': text},
    );

    return messageFromBackend(
      data['message'] as Map<String, dynamic>,
      requestId,
    );
  }
}

Message messageFromBackend(
    Map<String, dynamic> json, String fallbackRequestId) {
  final sender = json['sender'];
  final senderJson = sender is Map<String, dynamic> ? sender : null;
  final isSystem = json['type']?.toString() == 'system';

  return Message(
    id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
    requestId: _readRelationId(json['request'], fallbackRequestId),
    senderId: isSystem ? 'system' : _readRelationId(sender, ''),
    senderName: isSystem
        ? 'System'
        : senderJson == null
            ? 'User'
            : userFromBackend(senderJson).name,
    content: json['text']?.toString() ?? '',
    timestamp: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
    isRead: true,
    isSystemMessage: isSystem,
  );
}

String _readRelationId(dynamic value, String fallback) {
  if (value is Map<String, dynamic>) {
    return value['id']?.toString() ?? value['_id']?.toString() ?? fallback;
  }
  return value?.toString() ?? fallback;
}
