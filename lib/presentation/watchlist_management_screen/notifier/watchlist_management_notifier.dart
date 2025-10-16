import '../models/watchlist_management_model.dart';
import '../models/subscription_item_model.dart';
import '../../../core/app_export.dart';
import '../../../core/data_providers.dart';
import '../../../data/watchlist/watchlist_repository.dart';
import '../../../data/products/product_repository.dart';

part 'watchlist_management_state.dart';

final watchlistManagementNotifier = StateNotifierProvider.autoDispose<
    WatchlistManagementNotifier, WatchlistManagementState>(
  (ref) {
    final watchlistRepo = ref.watch(watchlistRepositoryProvider);
    final productRepo = ref.watch(productRepositoryProvider);
    return WatchlistManagementNotifier(
      WatchlistManagementState(
        watchlistManagementModel: WatchlistManagementModel(),
      ),
      watchlistRepository: watchlistRepo,
      productRepository: productRepo,
    );
  },
);

class WatchlistManagementNotifier
    extends StateNotifier<WatchlistManagementState> {
  final WatchlistRepository _watchlistRepository;
  final ProductRepository _productRepository;

  WatchlistManagementNotifier(
    WatchlistManagementState state, {
    required WatchlistRepository watchlistRepository,
    required ProductRepository productRepository,
  })  : _watchlistRepository = watchlistRepository,
        _productRepository = productRepository,
        super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(isLoading: true);
    loadWatchlist();
  }

  /// Load watchlist from repository
  Future<void> loadWatchlist() async {
    state = state.copyWith(isLoading: true, hasError: false);

    final watchlistResult = await _watchlistRepository.getWatchlist();

    if (watchlistResult.success) {
      // Fetch product details for all SKUs
      final productResult = await _productRepository.fetchProductsBySkus(watchlistResult.skus);

      // Convert SKUs to SubscriptionItemModel with product details
      final items = watchlistResult.skus.map((sku) {
        // Find product or use null if not found
        final products = productResult.products.where((p) => p.sku == sku).toList();
        final product = products.isNotEmpty ? products.first : null;
        return _createSubscriptionItem(sku, product);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        watchlistManagementModel:
            state.watchlistManagementModel?.copyWith(subscriptionItems: items),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: watchlistResult.error ?? 'Failed to load watchlist',
      );
    }
  }

  /// Unsubscribe from a SKU
  Future<void> onUnsubscribe(String sku) async {
    state = state.copyWith(isLoading: true);

    final watchlistResult = await _watchlistRepository.unsubscribe(sku);

    if (watchlistResult.success) {
      // Fetch product details for remaining SKUs
      final productResult = await _productRepository.fetchProductsBySkus(watchlistResult.skus);

      // Update local state with new SKU list
      final items = watchlistResult.skus.map((s) {
        // Find product or use null if not found
        final products = productResult.products.where((p) => p.sku == s).toList();
        final product = products.isNotEmpty ? products.first : null;
        return _createSubscriptionItem(s, product);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        watchlistManagementModel:
            state.watchlistManagementModel?.copyWith(subscriptionItems: items),
        isUnsubscribeSuccess: true,
        unsubscribedItemId: sku,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: watchlistResult.error ?? 'Failed to unsubscribe',
      );
    }
  }

  void resetUnsubscribeState() {
    state = state.copyWith(
      isUnsubscribeSuccess: false,
      unsubscribedItemId: null,
    );
  }

  /// Create a SubscriptionItemModel from SKU with product details
  SubscriptionItemModel _createSubscriptionItem(String sku, dynamic product) {
    if (product != null) {
      // Use real product details
      return SubscriptionItemModel(
        sku: sku,
        storeIcon: ImageConstant.imgEllipse10,
        storeName: product.store ?? 'Multiple Stores',
        productImage: product.imageUrl ?? ImageConstant.imgRectangle70,
        productName: product.name,
        id: sku,
      );
    }

    // Fallback to generic item if no product details
    return SubscriptionItemModel(
      sku: sku,
      storeIcon: ImageConstant.imgEllipse10,
      storeName: 'Unknown',
      productImage: ImageConstant.imgRectangle70,
      productName: 'Product $sku',
      id: sku,
    );
  }
}
