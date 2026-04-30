import '../models/message_model.dart';
import '../models/request_model.dart';
import 'mock_data_service.dart';
import 'storage_service.dart';

class MessageService {
  final StorageService _storage;
  final Map<String, List<Message>> _messagesByRequest = {};

  MessageService(this._storage);

  Future<void> init() async {}

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

  Future<Message> sendMessage({
    required String requestId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
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
    if (!_messagesByRequest.containsKey(request.id)) {
      _messagesByRequest[request.id] = [];
    }

    final systemMessage = MockDataService.generateSystemMessage(
      request.id,
      'Cererea a fost acceptată',
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
    String content;
    switch (status) {
      case 'inProgress':
        content = 'Cererea este acum în lucru';
        break;
      case 'completed':
        content = 'Cererea a fost finalizată';
        break;
      case 'cancelled':
        content = 'Cererea a fost anulată';
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
}
