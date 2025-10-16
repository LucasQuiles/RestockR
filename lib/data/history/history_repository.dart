import 'dart:async';
import 'models/history_result.dart';

/// Repository interface for restock history operations
/// Provides access to historical restock data with aggregation and filtering
abstract class HistoryRepository {
  /// Fetch restock history aggregated by time period
  ///
  /// Parameters:
  /// - startDate: Beginning of date range (inclusive)
  /// - endDate: End of date range (inclusive)
  /// - sku: Optional SKU filter
  /// - retailer: Optional retailer/store filter
  /// - groupBy: Aggregation period ('hour', 'date', 'month')
  /// - mode: Aggregation mode ('count' or 'reactions')
  ///
  /// Returns HistoryResult with aggregated data
  Future<HistoryResult> fetchHistory({
    required DateTime startDate,
    required DateTime endDate,
    String? sku,
    String? retailer,
    String groupBy = 'date',
    String mode = 'count',
  });

  /// Fetch detailed restock alerts for a specific time period
  ///
  /// Parameters:
  /// - date: Specific date to fetch (UTC)
  /// - hour: Optional hour filter (0-23)
  /// - limit: Maximum number of results
  ///
  /// Returns HistoryResult with detailed alert list
  Future<HistoryResult> fetchHistoryDetails({
    required DateTime date,
    int? hour,
    int limit = 100,
  });

  /// Dispose resources (e.g., close HTTP client)
  void dispose();
}
