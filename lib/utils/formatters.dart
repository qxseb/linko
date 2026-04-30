import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Acum';
        }
        return 'Acum ${difference.inMinutes}m';
      }
      return 'Acum ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return 'Acum ${difference.inDays}z';
    } else {
      return DateFormat('d MMM y').format(date);
    }
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM y • HH:mm').format(date);
  }

  static String formatPreferredTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Azi la ${formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Mâine la ${formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat('EEEE').format(date)} la ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }
}
