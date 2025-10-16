import 'package:equatable/equatable.dart';

/// Watchlist item representing a subscribed SKU
class WatchlistItem extends Equatable {
  final String sku;
  final DateTime subscribedAt;

  const WatchlistItem({
    required this.sku,
    required this.subscribedAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      sku: json['sku'] ?? '',
      subscribedAt: json['subscribedAt'] != null
          ? DateTime.parse(json['subscribedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'subscribedAt': subscribedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [sku, subscribedAt];
}

/// Result wrapper for watchlist operations
class WatchlistResult extends Equatable {
  final bool success;
  final List<String> skus;
  final String? error;

  const WatchlistResult({
    required this.success,
    required this.skus,
    this.error,
  });

  factory WatchlistResult.successResult(List<String> skus) {
    return WatchlistResult(
      success: true,
      skus: skus,
    );
  }

  factory WatchlistResult.failure(String error) {
    return WatchlistResult(
      success: false,
      skus: const [],
      error: error,
    );
  }

  @override
  List<Object?> get props => [success, skus, error];
}
