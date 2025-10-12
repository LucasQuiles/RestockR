import '../../../core/app_export.dart';

/// This class is used in the [watchlist_item_widget] component.

// ignore_for_file: must_be_immutable
class WatchlistItemModel extends Equatable {
  WatchlistItemModel({
    this.sku,
    this.storeIcon,
    this.storeName,
    this.productImage,
    this.productName,
    this.isSubscribed,
  }) {
    sku = sku ?? '12315494';
    storeIcon = storeIcon ?? ImageConstant.imgEllipse10;
    storeName = storeName ?? 'BestBuy';
    productImage = productImage ?? ImageConstant.imgRectangle70;
    productName = productName ?? 'Prismatic Booster Bundle';
    isSubscribed = isSubscribed ?? false;
  }

  String? sku;
  String? storeIcon;
  String? storeName;
  String? productImage;
  String? productName;
  bool? isSubscribed;

  WatchlistItemModel copyWith({
    String? sku,
    String? storeIcon,
    String? storeName,
    String? productImage,
    String? productName,
    bool? isSubscribed,
  }) {
    return WatchlistItemModel(
      sku: sku ?? this.sku,
      storeIcon: storeIcon ?? this.storeIcon,
      storeName: storeName ?? this.storeName,
      productImage: productImage ?? this.productImage,
      productName: productName ?? this.productName,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  @override
  List<Object?> get props => [
        sku,
        storeIcon,
        storeName,
        productImage,
        productName,
        isSubscribed,
      ];
}
