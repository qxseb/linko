enum NotificationType {
  newRequest,
  requestAccepted,
  requestInProgress,
  requestCompleted,
  requestCancelled,
  newMessage,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? requestId;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.requestId,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'title': title,
    'message': message,
    'requestId': requestId,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'],
        userId: json['userId'],
        type: NotificationType.values.firstWhere((e) => e.name == json['type']),
        title: json['title'],
        message: json['message'],
        requestId: json['requestId'],
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'] ?? false,
      );
}
