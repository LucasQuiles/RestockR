import '../../../core/app_export.dart';
import '../models/product_watchlist_model.dart';
import '../models/watchlist_item_model.dart';
import '../../../data/watchlist/watchlist_repository.dart';
import '../../../data/products/product_repository.dart';

part 'product_watchlist_state.dart';

final productWatchlistNotifier = StateNotifierProvider.autoDispose<
    ProductWatchlistNotifier, ProductWatchlistState>(
  (ref) {
    final watchlistRepo = ref.watch(watchlistRepositoryProvider);
    final productRepo = ref.watch(productRepositoryProvider);
    return ProductWatchlistNotifier(
      ProductWatchlistState(
        productWatchlistModel: ProductWatchlistModel(),
      ),
      watchlistRepository: watchlistRepo,
      productRepository: productRepo,
    );
  },
);

class ProductWatchlistNotifier extends StateNotifier<ProductWatchlistState> {
  final WatchlistRepository _watchlistRepository;
  final ProductRepository _productRepository;
  List<WatchlistItemModel> _allItems = [];

  ProductWatchlistNotifier(
    ProductWatchlistState state, {
    required WatchlistRepository watchlistRepository,
    required ProductRepository productRepository,
  })  : _watchlistRepository = watchlistRepository,
        _productRepository = productRepository,
        super(state) {
    initialize();
  }

  void initialize() {
    loadProducts();
  }

  /// Load products from backend and merge with user subscriptions
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      // Fetch all products
      final productResult = await _productRepository.fetchAllProducts();

      if (!productResult.success) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: productResult.error ?? 'Failed to load products',
        );
        return;
      }

      // Fetch user's watchlist
      final watchlistResult = await _watchlistRepository.getWatchlist();

      if (!watchlistResult.success) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: watchlistResult.error ?? 'Failed to load watchlist',
        );
        return;
      }

      // Convert products to WatchlistItemModel with subscription status
      final subscribedSkus = watchlistResult.skus.toSet();
      _allItems = productResult.products.map((product) {
        return WatchlistItemModel(
          sku: product.sku,
          storeIcon: ImageConstant.imgEllipse10,
          storeName: product.store ?? 'Multiple Stores',
          productImage: product.imageUrl ?? ImageConstant.imgRectangle70,
          productName: product.name,
          isSubscribed: subscribedSkus.contains(product.sku),
        );
      }).toList();

      _updateVisibleItems();

      state = state.copyWith(
        isLoading: false,
        subscribedCount: subscribedSkus.length,
      );
    } catch (e) {
      print('🔥 Error loading products: $e');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  void changeTab(int index) {
    state = state.copyWith(
      selectedTabIndex: index,
    );
  }

  /// Toggle subscription for an item with API persistence
  Future<void> toggleSubscription(WatchlistItemModel item) async {
    final wasSubscribed = item.isSubscribed ?? false;
    final sku = item.sku ?? '';

    if (sku.isEmpty) {
      print('⚠️ Cannot toggle subscription: SKU is empty');
      return;
    }

    // Optimistically update UI
    _allItems = _allItems.map((existing) {
      if (existing.sku == sku) {
        return existing.copyWith(
          isSubscribed: !wasSubscribed,
        );
      }
      return existing;
    }).toList();
    _updateVisibleItems();

    // Update subscribed count
    final newCount = _allItems.where((item) => item.isSubscribed ?? false).length;
    state = state.copyWith(subscribedCount: newCount);

    try {
      // Call appropriate API
      final result = wasSubscribed
          ? await _watchlistRepository.unsubscribe(sku)
          : await _watchlistRepository.subscribe(sku);

      if (!result.success) {
        // Revert on failure
        _allItems = _allItems.map((existing) {
          if (existing.sku == sku) {
            return existing.copyWith(
              isSubscribed: wasSubscribed,
            );
          }
          return existing;
        }).toList();
        _updateVisibleItems();

        // Revert count
        final revertedCount = _allItems.where((item) => item.isSubscribed ?? false).length;
        state = state.copyWith(
          subscribedCount: revertedCount,
          hasError: true,
          errorMessage: result.error ?? 'Failed to update subscription',
        );

        print('❌ Subscription toggle failed: ${result.error}');
      } else {
        print('✅ Subscription ${wasSubscribed ? "removed" : "added"}: $sku');
      }
    } catch (e) {
      print('🔥 Error toggling subscription: $e');

      // Revert on error
      _allItems = _allItems.map((existing) {
        if (existing.sku == sku) {
          return existing.copyWith(
            isSubscribed: wasSubscribed,
          );
        }
        return existing;
      }).toList();
      _updateVisibleItems();

      final revertedCount = _allItems.where((item) => item.isSubscribed ?? false).length;
      state = state.copyWith(
        subscribedCount: revertedCount,
        hasError: true,
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  void searchProducts(String query) {
    state = state.copyWith(
      searchQuery: query,
    );

    _updateVisibleItems();
  }

  void _updateVisibleItems() {
    final query = (state.searchQuery ?? '').trim().toLowerCase();

    final filteredItems = query.isEmpty
        ? _allItems
        : _allItems
            .where(
              (item) =>
                  (item.productName ?? '').toLowerCase().contains(query) ||
                  (item.sku ?? '').toLowerCase().contains(query),
            )
            .toList();

    state = state.copyWith(
      isLoading: false,
      productWatchlistModel:
          state.productWatchlistModel?.copyWith(watchlistItems: filteredItems),
      subscribedCount:
          _allItems.where((item) => item.isSubscribed ?? false).length,
    );
  }
}
