import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const _uuid = Uuid();
  final Map<String, List<AppNotification>> _notificationsByUser = {};

  List<AppNotification> getNotificationsForUser(String userId) {
    return List.unmodifiable(
      _notificationsByUser[userId] ?? [],
    );
  }

  int getUnreadCount(String userId) {
    return getNotificationsForUser(userId)
        .where((n) => !n.isRead)
        .length;
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    final notifications = _notificationsByUser[userId];
    if (notifications == null) return;
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    final n = notifications[index];
    notifications[index] = AppNotification(
      id: n.id,
      userId: n.userId,
      type: n.type,
      title: n.title,
      message: n.message,
      requestId: n.requestId,
      timestamp: n.timestamp,
      isRead: true,
    );
  }

  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? requestId,
  }) async {
    final notification = AppNotification(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      title: title,
      message: message,
      requestId: requestId,
      timestamp: DateTime.now(),
    );
    _notificationsByUser.putIfAbsent(userId, () => []);
    _notificationsByUser[userId]!.insert(0, notification);
  }
}
