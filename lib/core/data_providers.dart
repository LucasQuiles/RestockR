import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/restocks/restock_feed_repository.dart';
import '../data/restocks/restock_feed_repository_mock.dart';
import '../data/restocks/restock_feed_repository_impl.dart';
import '../data/watchlist/watchlist_repository.dart';
import '../data/watchlist/watchlist_repository_mock.dart';
import '../data/watchlist/watchlist_repository_impl.dart';
import '../data/history/history_repository.dart';
import '../data/history/history_repository_mock.dart';
import '../data/history/history_repository_impl.dart';
import '../data/products/product_repository.dart';
import '../data/products/product_repository_mock.dart';
import '../data/products/product_repository_impl.dart';
import 'config/backend_config.dart';

/// Provider for RestockFeedRepository
/// Switches between mock and real implementation based on environment
final restockFeedRepositoryProvider = Provider<RestockFeedRepository>((ref) {
  final config = ref.watch(backendConfigProvider);

  final RestockFeedRepository repository;
  if (config.environment == 'development' || config.environment == 'local') {
    repository = MockRestockFeedRepository();
  } else {
    repository = RestockFeedRepositoryImpl(config: config);
  }

  ref.onDispose(repository.dispose);
  return repository;
});

/// Provider for WatchlistRepository
/// Switches between mock and real implementation based on environment
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  final config = ref.watch(backendConfigProvider);

  final WatchlistRepository repository;
  if (config.environment == 'development' || config.environment == 'local') {
    repository = MockWatchlistRepository();
  } else {
    repository = WatchlistRepositoryImpl(config: config);
  }

  ref.onDispose(repository.dispose);
  return repository;
});

/// Provider for HistoryRepository
/// Switches between mock and real implementation based on environment
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final config = ref.watch(backendConfigProvider);

  final HistoryRepository repository;
  if (config.environment == 'development' || config.environment == 'local') {
    repository = MockHistoryRepository();
  } else {
    repository = HistoryRepositoryImpl(config: config);
  }

  ref.onDispose(repository.dispose);
  return repository;
});

/// Provider for ProductRepository
/// Switches between mock and real implementation based on environment
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final config = ref.watch(backendConfigProvider);

  final ProductRepository repository;
  if (config.environment == 'development' || config.environment == 'local') {
    repository = MockProductRepository();
  } else {
    repository = ProductRepositoryImpl(config: config);
  }

  ref.onDispose(repository.dispose);
  return repository;
});
