import '../models/notification_model.dart';
import 'mock_data_service.dart';

class NotificationService {
  final Map<String, List<AppNotification>> _notificationsByUser = {};

  List<AppNotification> getNotificationsForUser(String userId) {
    if (!_notificationsByUser.containsKey(userId)) {
      _notificationsByUser[userId] = MockDataService.getMockNotifications(
        userId,
      );
    }
    return List.unmodifiable(_notificationsByUser[userId]!);
  }

  int getUnreadCount(String userId) {
    final notifications = getNotificationsForUser(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_notificationsByUser.containsKey(userId)) {
      final index = _notificationsByUser[userId]!.indexWhere(
        (n) => n.id == notificationId,
      );
      if (index != -1) {
        final notification = _notificationsByUser[userId]![index];
        _notificationsByUser[userId]![index] = AppNotification(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          requestId: notification.requestId,
          timestamp: notification.timestamp,
          isRead: true,
        );
      }
    }
  }

  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? requestId,
  }) async {
    final notification = AppNotification(
      id: MockDataService.generateId(),
      userId: userId,
      type: type,
      title: title,
      message: message,
      requestId: requestId,
      timestamp: DateTime.now(),
    );

    if (!_notificationsByUser.containsKey(userId)) {
      _notificationsByUser[userId] = [];
    }
    _notificationsByUser[userId]!.insert(0, notification);
  }
}
