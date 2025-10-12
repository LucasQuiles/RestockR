import '../../../core/app_export.dart';

/// This class is used in the [monitor_item_widget] component.

// ignore_for_file: must_be_immutable
class MonitorItemModel extends Equatable {
  MonitorItemModel({
    this.date,
    this.time,
    this.productImage,
    this.productTitle,
    this.storeIcon,
    this.storeName,
    this.quantity,
    this.price,
    this.downVoteCount,
    this.upVoteCount,
  }) {
    date = date ?? "";
    time = time ?? "";
    productImage = productImage ?? "";
    productTitle = productTitle ?? "";
    storeIcon = storeIcon ?? "";
    storeName = storeName ?? "";
    quantity = quantity ?? "";
    price = price ?? "";
    downVoteCount = downVoteCount ?? 0;
    upVoteCount = upVoteCount ?? 0;
  }

  String? date;
  String? time;
  String? productImage;
  String? productTitle;
  String? storeIcon;
  String? storeName;
  String? quantity;
  String? price;
  int? downVoteCount;
  int? upVoteCount;

  MonitorItemModel copyWith({
    String? date,
    String? time,
    String? productImage,
    String? productTitle,
    String? storeIcon,
    String? storeName,
    String? quantity,
    String? price,
    int? downVoteCount,
    int? upVoteCount,
  }) {
    return MonitorItemModel(
      date: date ?? this.date,
      time: time ?? this.time,
      productImage: productImage ?? this.productImage,
      productTitle: productTitle ?? this.productTitle,
      storeIcon: storeIcon ?? this.storeIcon,
      storeName: storeName ?? this.storeName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      downVoteCount: downVoteCount ?? this.downVoteCount,
      upVoteCount: upVoteCount ?? this.upVoteCount,
    );
  }

  @override
  List<Object?> get props => [
        date,
        time,
        productImage,
        productTitle,
        storeIcon,
        storeName,
        quantity,
        price,
        downVoteCount,
        upVoteCount,
      ];
}
