import 'watchlist_repository.dart';
import 'models/watchlist_item.dart';

/// Mock implementation of WatchlistRepository for development
class MockWatchlistRepository implements WatchlistRepository {
  final Set<String> _subscribedSkus = {
    '12315494', // Default mock subscriptions
    '87654321',
    '11223344',
  };

  @override
  Future<WatchlistResult> getWatchlist() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return WatchlistResult.successResult(_subscribedSkus.toList());
  }

  @override
  Future<WatchlistResult> subscribe(String sku) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_subscribedSkus.contains(sku)) {
      return WatchlistResult.failure('Already subscribed to this SKU');
    }

    _subscribedSkus.add(sku);
    return WatchlistResult.successResult(_subscribedSkus.toList());
  }

  @override
  Future<WatchlistResult> unsubscribe(String sku) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_subscribedSkus.contains(sku)) {
      return WatchlistResult.failure('Not subscribed to this SKU');
    }

    _subscribedSkus.remove(sku);
    return WatchlistResult.successResult(_subscribedSkus.toList());
  }

  @override
  Future<bool> isSubscribed(String sku) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _subscribedSkus.contains(sku);
  }

  @override
  void dispose() {
    // No cleanup needed for mock
  }
}
