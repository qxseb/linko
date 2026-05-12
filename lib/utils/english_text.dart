import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import '../models/message_model.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import 'date_time_utils.dart';

extension RequestCategoryText on RequestCategory {
  String get label {
    switch (this) {
      case RequestCategory.groceries:
        return 'Groceries';
      case RequestCategory.pharmacy:
        return 'Pharmacy';
      case RequestCategory.errands:
        return 'Errands';
      case RequestCategory.checkIn:
        return 'Check-in';
    }
  }
}

extension RequestUrgencyText on RequestUrgency {
  String get label {
    switch (this) {
      case RequestUrgency.low:
        return 'Low';
      case RequestUrgency.medium:
        return 'Medium';
      case RequestUrgency.high:
        return 'High';
    }
  }
}

extension RequestStatusText on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.open:
        return 'Open';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.inProgress:
        return 'In progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension UserText on User {
  String get trustLevelLabel {
    if (completedTasks == 0) return 'New';
    if (completedTasks < 5) return 'Active';
    return 'Trusted';
  }

  String get lastActiveText {
    if (lastActive == null) return 'Joined recently';
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inMinutes < 60) return 'Active now';
    if (diff.inHours < 24) return 'Active today';
    if (diff.inDays == 1) return 'Active yesterday';
    if (diff.inDays < 7) return 'Active this week';
    return 'Active ${diff.inDays} days ago';
  }

  String get responseTimeText {
    if (avgResponseMinutes == null) return 'New volunteer';
    if (avgResponseMinutes! < 15) return 'Responds quickly';
    if (avgResponseMinutes! < 60) return 'Responds within 1h';
    return 'Responds the same day';
  }
}

String formatTimeText(DateTime date) =>
    DateFormat.Hm().format(localDateTime(date));

String formatDateTimeText(DateTime date) {
  return DateFormat.yMMMd().add_Hm().format(localDateTime(date));
}

String formatPreferredTimeText(DateTime date) {
  date = localDateTime(date);
  final now = DateTime.now();
  final difference = date.difference(now);
  final time = formatTimeText(date);

  if (difference.inDays == 0) return 'Today at $time';
  if (difference.inDays == 1) return 'Tomorrow at $time';
  if (difference.inDays < 7) {
    final weekday = DateFormat.EEEE().format(date);
    return '$weekday at $time';
  }
  return formatDateTimeText(date);
}

String friendlyErrorMessage(String error) {
  final normalized = error.replaceFirst('Exception: ', '').toLowerCase();

  if (normalized.contains('invalid credentials') ||
      normalized.contains('incorrect')) {
    return 'Invalid email or password';
  }
  if (normalized.contains('account with this email')) {
    return 'An account with this email already exists';
  }
  if (normalized.contains('not authenticated')) {
    return 'Please sign in again';
  }
  if (normalized.contains('request not found')) {
    return 'Request not found';
  }
  if (normalized.contains('already accepted')) {
    return 'This request has already been accepted';
  }
  if (normalized.contains('server is currently unavailable') ||
      normalized.contains('server is not responding') ||
      normalized.contains('could not connect to the server') ||
      normalized.contains('failed host lookup') ||
      normalized.contains('socketexception')) {
    return 'Live backend is offline. Start the server, retry, or switch to Demo Mode.';
  }
  return 'Something went wrong. Please try again.';
}

String messageContentText(Message message) {
  if (message.isSystemMessage) {
    switch (message.content) {
      case 'request_accepted':
        return 'Request accepted';
      case 'request_in_progress':
        return 'Request is now in progress';
      case 'request_completed':
        return 'Request completed';
      case 'request_cancelled':
        return 'Request cancelled';
    }
  }

  return message.content;
}

String requestDescriptionText(Request request) => request.description;

String requestLocationText(
  Request request, {
  double? userLatitude,
  double? userLongitude,
}) {
  final location = stripDistanceFromLocation(request.location);

  if (userLatitude == null ||
      userLongitude == null ||
      request.latitude == null ||
      request.longitude == null) {
    return location;
  }

  final meters = Geolocator.distanceBetween(
    userLatitude,
    userLongitude,
    request.latitude!,
    request.longitude!,
  );

  return '$location (${formatDistance(meters)})';
}

String stripDistanceFromLocation(String location) {
  return location.replaceFirst(
    RegExp(r'\s*\((?:\d+(?:[.,]\d+)?\s*km|\d+\s*m)\)\s*$'),
    '',
  );
}

String formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.round()} m';
  }
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
