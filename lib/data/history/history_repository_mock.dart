import 'dart:async';
import 'dart:math';
import 'history_repository.dart';
import 'models/history_result.dart';
import 'models/history_aggregation.dart';
import 'models/history_alert.dart';

/// Mock implementation of HistoryRepository for development and testing
class MockHistoryRepository implements HistoryRepository {
  final Random _random = Random();

  @override
  Future<HistoryResult> fetchHistory({
    required DateTime startDate,
    required DateTime endDate,
    String? sku,
    String? retailer,
    String groupBy = 'date',
    String mode = 'count',
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));

    print('📊 Mock: Fetching history from $startDate to $endDate');

    // Generate mock aggregations for each day in the range
    final aggregations = <HistoryAggregation>[];
    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      // Random count between 0-15
      final count = _random.nextInt(16);

      aggregations.add(HistoryAggregation(
        period: current.toIso8601String().split('T')[0],
        count: count,
        yesReactions: mode == 'reactions' ? _random.nextInt(count + 1) : null,
        noReactions: mode == 'reactions' ? _random.nextInt(count + 1) : null,
      ));

      current = current.add(Duration(days: 1));
    }

    return HistoryResult.successWithAggregations(aggregations);
  }

  @override
  Future<HistoryResult> fetchHistoryDetails({
    required DateTime date,
    int? hour,
    int limit = 100,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 600));

    print('📊 Mock: Fetching details for $date, hour: $hour');

    // Generate 5-10 mock alerts for the requested date
    final alertCount = 5 + _random.nextInt(6);
    final alerts = List.generate(alertCount, (index) {
      final stores = ['Target', 'Amazon', 'Walmart', 'BestBuy', 'Costco'];
      final products = [
        'PlayStation 5 Console',
        'Xbox Series X',
        'Nintendo Switch OLED',
        'Apple AirPods Pro',
        'Samsung Galaxy S24',
      ];

      return HistoryAlert(
        id: 'mock-${date.millisecondsSinceEpoch}-$index',
        store: stores[_random.nextInt(stores.length)],
        sku: '${100000 + _random.nextInt(900000)}',
        product: products[_random.nextInt(products.length)],
        price: 99.99 + _random.nextDouble() * 400,
        url: 'https://example.com/product/$index',
        image: null,
        timestamp: date.add(Duration(
          hours: hour ?? _random.nextInt(24),
          minutes: _random.nextInt(60),
        )),
        yesReactions: _random.nextInt(10),
        noReactions: _random.nextInt(5),
      );
    });

    return HistoryResult.successWithAlerts(alerts);
  }

  @override
  void dispose() {
    // No resources to dispose in mock
  }
}
