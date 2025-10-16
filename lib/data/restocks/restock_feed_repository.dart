import 'models/restock_alert.dart';
import 'models/restock_feed_result.dart';

/// Abstract interface for restock feed operations
abstract class RestockFeedRepository {
  /// Fetch recent restock alerts
  /// Returns the most recent alerts, up to [limit] items
  Future<RestockFeedResult> getRecentAlerts({int limit = 25});

  /// Submit a reaction (yes/no) to a restock alert
  /// [alertId] - The alert ID to react to
  /// [isPositive] - true for upvote/yes, false for downvote/no
  Future<bool> submitReaction(String alertId, bool isPositive);

  /// Stream of real-time restock alerts (WebSocket-based)
  /// Returns null if WebSocket is not available
  Stream<RestockAlert>? get alertStream;

  /// Clean up resources
  void dispose();
}
