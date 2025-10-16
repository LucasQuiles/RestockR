import 'history_aggregation.dart';
import 'history_alert.dart';

/// Result wrapper for history repository operations
class HistoryResult {
  final List<HistoryAggregation> aggregations;
  final List<HistoryAlert> alerts;
  final String? error;
  final bool success;

  const HistoryResult({
    this.aggregations = const [],
    this.alerts = const [],
    this.error,
    required this.success,
  });

  factory HistoryResult.successWithAggregations(List<HistoryAggregation> aggregations) {
    return HistoryResult(
      aggregations: aggregations,
      alerts: const [],
      success: true,
    );
  }

  factory HistoryResult.successWithAlerts(List<HistoryAlert> alerts) {
    return HistoryResult(
      aggregations: const [],
      alerts: alerts,
      success: true,
    );
  }

  factory HistoryResult.failure(String error) {
    return HistoryResult(
      aggregations: const [],
      alerts: const [],
      error: error,
      success: false,
    );
  }
}
