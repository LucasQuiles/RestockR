import '../../../core/app_export.dart';
import './watchlist_item_model.dart';

/// This class is used in the [product_watchlist_screen] screen.

// ignore_for_file: must_be_immutable
class ProductWatchlistModel extends Equatable {
  ProductWatchlistModel({
    this.watchlistItems,
  }) {
    watchlistItems = watchlistItems ?? _getDefaultWatchlistItems();
  }

  List<WatchlistItemModel>? watchlistItems;

  ProductWatchlistModel copyWith({
    List<WatchlistItemModel>? watchlistItems,
  }) {
    return ProductWatchlistModel(
      watchlistItems: watchlistItems ?? this.watchlistItems,
    );
  }

  List<WatchlistItemModel> _getDefaultWatchlistItems() {
    return [
      WatchlistItemModel(
        sku: '12315494',
        storeIcon: ImageConstant.imgEllipse10,
        storeName: 'BestBuy',
        productImage: ImageConstant.imgRectangle70,
        productName: 'Prismatic Booster Bundle',
        isSubscribed: false,
      ),
      WatchlistItemModel(
        sku: '12315494',
        storeIcon: ImageConstant.imgEllipse10,
        storeName: 'BestBuy',
        productImage: ImageConstant.imgRectangle70,
        productName: 'Prismatic Booster Bundle',
        isSubscribed: false,
      ),
      WatchlistItemModel(
        sku: '12315494',
        storeIcon: ImageConstant.imgEllipse10,
        storeName: 'BestBuy',
        productImage: ImageConstant.imgRectangle70,
        productName: 'Prismatic Booster Bundle',
        isSubscribed: false,
      ),
      WatchlistItemModel(
        sku: '12315494',
        storeIcon: ImageConstant.imgEllipse10,
        storeName: 'BestBuy',
        productImage: ImageConstant.imgRectangle70,
        productName: 'Prismatic Booster Bundle',
        isSubscribed: false,
      ),
    ];
  }

  @override
  List<Object?> get props => [watchlistItems];
}
