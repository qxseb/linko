import '../utils/date_time_utils.dart';

class Message {
  final String id;
  final String requestId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSystemMessage;

  Message({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isSystemMessage = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'requestId': requestId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'isSystemMessage': isSystemMessage,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        requestId: json['requestId'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        content: json['content'],
        timestamp: parseLocalDateTime(json['timestamp']) ?? DateTime.now(),
        isRead: json['isRead'] ?? false,
        isSystemMessage: json['isSystemMessage'] ?? false,
      );
}
