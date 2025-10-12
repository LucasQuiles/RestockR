import '../../../core/app_export.dart';
import './subscription_item_model.dart';

/// This class is used in the [watchlist_management_screen] screen.

// ignore_for_file: must_be_immutable
class WatchlistManagementModel extends Equatable {
  WatchlistManagementModel({
    this.subscriptionItems,
  }) {
    subscriptionItems = subscriptionItems ??
        [
          SubscriptionItemModel(
            sku: "12315494",
            storeIcon: ImageConstant.imgEllipse10,
            storeName: "BestBuy",
            productImage: ImageConstant.imgRectangle70,
            productName: "Prismatic Booster Bundle",
            id: "1",
          ),
          SubscriptionItemModel(
            sku: "12315494",
            storeIcon: ImageConstant.imgEllipse10,
            storeName: "BestBuy",
            productImage: ImageConstant.imgRectangle70,
            productName: "Prismatic Booster Bundle",
            id: "2",
          ),
          SubscriptionItemModel(
            sku: "12315494",
            storeIcon: ImageConstant.imgEllipse10,
            storeName: "BestBuy",
            productImage: ImageConstant.imgRectangle70,
            productName: "Prismatic Booster Bundle",
            id: "3",
          ),
          SubscriptionItemModel(
            sku: "12315494",
            storeIcon: ImageConstant.imgEllipse10,
            storeName: "BestBuy",
            productImage: ImageConstant.imgRectangle70,
            productName: "Prismatic Booster Bundle",
            id: "4",
          ),
        ];
  }

  List<SubscriptionItemModel>? subscriptionItems;

  WatchlistManagementModel copyWith({
    List<SubscriptionItemModel>? subscriptionItems,
  }) {
    return WatchlistManagementModel(
      subscriptionItems: subscriptionItems ?? this.subscriptionItems,
    );
  }

  @override
  List<Object?> get props => [subscriptionItems];
}
