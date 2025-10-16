import 'dart:async';
import 'dart:math';
import 'restock_feed_repository.dart';
import 'models/restock_alert.dart';
import 'models/restock_feed_result.dart';

/// Mock implementation of RestockFeedRepository for development
class MockRestockFeedRepository implements RestockFeedRepository {
  final _random = Random();
  final List<RestockAlert> _mockAlerts = [];
  StreamController<RestockAlert>? _alertStreamController;

  MockRestockFeedRepository() {
    _generateMockData();
  }

  void _generateMockData() {
    final stores = ['BestBuy', 'Amazon', 'Target', 'Walmart', 'GameStop'];
    final products = [
      'Magic: The Gathering | Avatar Collector Booster',
      'Pokemon Prismatic Booster Bundle',
      'Yu-Gi-Oh! Maximum Gold Tin',
      'Flesh and Blood: Outsiders Booster',
      'Disney Lorcana Chapter 5 Booster',
    ];

    final now = DateTime.now();
    for (int i = 0; i < 15; i++) {
      final timestamp = now.subtract(Duration(minutes: i * 5));
      _mockAlerts.add(
        RestockAlert(
          id: 'mock_${timestamp.millisecondsSinceEpoch}',
          store: stores[_random.nextInt(stores.length)],
          sku: '${100000 + _random.nextInt(900000)}',
          product: products[_random.nextInt(products.length)],
          price: '\$${(15 + _random.nextDouble() * 35).toStringAsFixed(2)}',
          url: 'https://example.com/product',
          image: null, // Will use placeholder in UI
          timestamp: timestamp,
          source: 'mock',
          reactions: RestockReactions(
            yes: _random.nextInt(100),
            no: _random.nextInt(30),
          ),
          reactedUsers: [],
        ),
      );
    }
  }

  @override
  Future<RestockFeedResult> getRecentAlerts({int limit = 25}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final alerts = _mockAlerts.take(limit).toList();
    return RestockFeedResult.success(alerts, hasMore: _mockAlerts.length > limit);
  }

  @override
  Future<bool> submitReaction(String alertId, bool isPositive) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Update mock data
    final index = _mockAlerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final alert = _mockAlerts[index];
      final updatedReactions = isPositive
          ? alert.reactions.copyWith(yes: alert.reactions.yes + 1)
          : alert.reactions.copyWith(no: alert.reactions.no + 1);

      _mockAlerts[index] = alert.copyWith(reactions: updatedReactions);
      return true;
    }

    return false;
  }

  @override
  Stream<RestockAlert>? get alertStream {
    // Mock WebSocket stream - emits a new alert every 10 seconds
    _alertStreamController ??= StreamController<RestockAlert>.broadcast();

    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_alertStreamController?.isClosed ?? true) {
        timer.cancel();
        return;
      }

      final stores = ['BestBuy', 'Amazon', 'Target', 'Walmart', 'GameStop'];
      final products = [
        'Magic: The Gathering | Avatar Collector Booster',
        'Pokemon Prismatic Booster Bundle',
      ];

      final newAlert = RestockAlert(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        store: stores[_random.nextInt(stores.length)],
        sku: '${100000 + _random.nextInt(900000)}',
        product: products[_random.nextInt(products.length)],
        price: '\$${(15 + _random.nextDouble() * 35).toStringAsFixed(2)}',
        url: 'https://example.com/product',
        image: null,
        timestamp: DateTime.now(),
        source: 'mock_stream',
        reactions: const RestockReactions(yes: 0, no: 0),
        reactedUsers: [],
      );

      _alertStreamController?.add(newAlert);
    });

    return _alertStreamController?.stream;
  }

  @override
  void dispose() {
    _alertStreamController?.close();
  }
}
