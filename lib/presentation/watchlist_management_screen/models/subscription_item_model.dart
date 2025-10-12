import '../../../core/app_export.dart';

/// This class is used in the [subscription_item_widget] widget.

// ignore_for_file: must_be_immutable
class SubscriptionItemModel extends Equatable {
  SubscriptionItemModel({
    this.sku,
    this.storeIcon,
    this.storeName,
    this.productImage,
    this.productName,
    this.id,
  }) {
    sku = sku ?? "12315494";
    storeIcon = storeIcon ?? ImageConstant.imgEllipse10;
    storeName = storeName ?? "BestBuy";
    productImage = productImage ?? ImageConstant.imgRectangle70;
    productName = productName ?? "Prismatic Booster Bundle";
    id = id ?? "";
  }

  String? sku;
  String? storeIcon;
  String? storeName;
  String? productImage;
  String? productName;
  String? id;

  SubscriptionItemModel copyWith({
    String? sku,
    String? storeIcon,
    String? storeName,
    String? productImage,
    String? productName,
    String? id,
  }) {
    return SubscriptionItemModel(
      sku: sku ?? this.sku,
      storeIcon: storeIcon ?? this.storeIcon,
      storeName: storeName ?? this.storeName,
      productImage: productImage ?? this.productImage,
      productName: productName ?? this.productName,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props =>
      [sku, storeIcon, storeName, productImage, productName, id];
}
