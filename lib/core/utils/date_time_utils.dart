import 'package:intl/intl.dart';

/// Centralized date/time formatting utilities
/// All functions automatically convert UTC timestamps to local timezone
class DateTimeUtils {
  /// Format date and time in full format
  /// Example: "Monday, Jan 1, 2025 at 3:45 PM"
  static String formatFullDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final date = DateFormat('EEEE, MMM d, yyyy').format(localTime);
    final time = DateFormat('h:mm a').format(localTime);
    return '$date at $time';
  }

  /// Format date only
  /// Example: "Monday, Jan 1, 2025"
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime.toLocal());
  }

  /// Format short date
  /// Example: "Mon, 01 Jan"
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('E, dd MMM').format(dateTime.toLocal());
  }

  /// Format time only with seconds
  /// Example: "03:45:23 PM"
  static String formatTimeWithSeconds(DateTime dateTime) {
    return DateFormat('hh:mm:ss a').format(dateTime.toLocal());
  }

  /// Format time only without seconds
  /// Example: "3:45 PM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  /// Format month and year
  /// Example: "January 2025"
  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy').format(dateTime.toLocal());
  }

  /// Format relative time (e.g., "2 hours ago", "just now")
  static String formatRelativeTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Parse ISO 8601 string to DateTime (keeps as UTC)
  /// Use .toLocal() when displaying to user
  static DateTime parseIso8601(String iso8601String) {
    return DateTime.parse(iso8601String);
  }

  /// Get current local time
  static DateTime now() {
    return DateTime.now();
  }

  /// Check if two dates are on the same day (ignoring time)
  static bool isSameDay(DateTime date1, DateTime date2) {
    final local1 = date1.toLocal();
    final local2 = date2.toLocal();
    return local1.year == local2.year &&
        local1.month == local2.month &&
        local1.day == local2.day;
  }
}
