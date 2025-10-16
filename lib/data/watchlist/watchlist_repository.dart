import 'models/watchlist_item.dart';

/// Abstract interface for watchlist/subscription operations
abstract class WatchlistRepository {
  /// Get the current user's subscribed SKUs
  Future<WatchlistResult> getWatchlist();

  /// Subscribe to a SKU
  Future<WatchlistResult> subscribe(String sku);

  /// Unsubscribe from a SKU
  Future<WatchlistResult> unsubscribe(String sku);

  /// Check if user is subscribed to a specific SKU
  Future<bool> isSubscribed(String sku);

  /// Clean up resources
  void dispose();
}
