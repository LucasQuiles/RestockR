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
  ProductWatchlistNotifier(ProductWatchlistState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      isLoading: false,
      selectedTabIndex: 0,
    );
  }

  void changeTab(int index) {
    state = state.copyWith(
      selectedTabIndex: index,
    );
  }

  void toggleSubscription(int index) {
    final items = state.productWatchlistModel?.watchlistItems ?? [];
    if (index < items.length) {
      final updatedItems = List<WatchlistItemModel>.from(
          items); // Modified: Fixed type casting to List<WatchlistItemModel>
      final currentItem = updatedItems[index];
      updatedItems[index] = currentItem.copyWith(
        isSubscribed: !(currentItem.isSubscribed ?? false),
      );

      final updatedModel = state.productWatchlistModel?.copyWith(
        watchlistItems: updatedItems,
      );

      state = state.copyWith(
        productWatchlistModel: updatedModel,
      );
    }
  }

  void searchProducts(String query) {
    state = state.copyWith(
      searchQuery: query,
      isLoading: true,
    );

    // Simulate search delay
    Future.delayed(Duration(milliseconds: 500), () {
      state = state.copyWith(
        isLoading: false,
      );
    });
  }
}
