import '../../../core/app_export.dart';
import '../models/product_watchlist_model.dart';
import '../models/watchlist_item_model.dart';

part 'product_watchlist_state.dart';

final productWatchlistNotifier = StateNotifierProvider.autoDispose<
    ProductWatchlistNotifier, ProductWatchlistState>(
  (ref) => ProductWatchlistNotifier(
    ProductWatchlistState(
      productWatchlistModel: ProductWatchlistModel(),
    ),
  ),
);

class ProductWatchlistNotifier extends StateNotifier<ProductWatchlistState> {
  ProductWatchlistNotifier(ProductWatchlistState state)
      : _allItems = List<WatchlistItemModel>.from(
            state.productWatchlistModel?.watchlistItems ?? []),
        super(state) {
    initialize();
  }

  List<WatchlistItemModel> _allItems;

  void initialize() {
    state = state.copyWith(
      isLoading: false,
      selectedTabIndex: 0,
      productWatchlistModel: state.productWatchlistModel?.copyWith(
        watchlistItems: _allItems,
      ),
      subscribedCount:
          _allItems.where((item) => item.isSubscribed ?? false).length,
    );
  }

  void changeTab(int index) {
    state = state.copyWith(
      selectedTabIndex: index,
    );
  }

  void toggleSubscription(WatchlistItemModel item) {
    _allItems = _allItems.map((existing) {
      if (existing.sku == item.sku) {
        return existing.copyWith(
          isSubscribed: !(existing.isSubscribed ?? false),
        );
      }
      return existing;
    }).toList();

    _updateVisibleItems();
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
