import 'package:equatable/equatable.dart';
import 'restock_alert.dart';

/// Result wrapper for restock feed operations
class RestockFeedResult extends Equatable {
  final List<RestockAlert> alerts;
  final bool hasMore;
  final String? error;

  const RestockFeedResult({
    required this.alerts,
    this.hasMore = false,
    this.error,
  });

  factory RestockFeedResult.success(List<RestockAlert> alerts,
      {bool hasMore = false}) {
    return RestockFeedResult(
      alerts: alerts,
      hasMore: hasMore,
    );
  }

  factory RestockFeedResult.failure(String error) {
    return RestockFeedResult(
      alerts: const [],
      error: error,
    );
  }

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  @override
  List<Object?> get props => [alerts, hasMore, error];
}
