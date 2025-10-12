import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/monitor_item_model.dart';
import '../models/product_monitor_model.dart';

part 'product_monitor_state.dart';

final productMonitorNotifier = StateNotifierProvider.autoDispose<
    ProductMonitorNotifier, ProductMonitorState>(
  (ref) => ProductMonitorNotifier(
    ProductMonitorState(
      productMonitorModel: ProductMonitorModel(),
    ),
  ),
);

class ProductMonitorNotifier extends StateNotifier<ProductMonitorState> {
  ProductMonitorNotifier(ProductMonitorState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      searchController: TextEditingController(),
      selectedTabIndex: 0,
      isLoading: false,
      productMonitorModel: ProductMonitorModel(
        monitorItems: _generateSampleData(),
      ),
    );
  }

  void onSearchChanged(String value) {
    // Handle search functionality
    state = state.copyWith(
      searchQuery: value,
    );
  }

  void onTabChanged(int index) {
    state = state.copyWith(
      selectedTabIndex: index,
    );
  }

  void onDownVote(int index) {
    final items = List<MonitorItemModel>.from(
        state.productMonitorModel?.monitorItems ?? []);
    if (index < items.length) {
      items[index] = items[index].copyWith(
        downVoteCount: (items[index].downVoteCount ?? 0) + 1,
      );

      state = state.copyWith(
        productMonitorModel: state.productMonitorModel?.copyWith(
          monitorItems: items,
        ),
      );
    }
  }

  void onUpVote(int index) {
    final items = List<MonitorItemModel>.from(
        state.productMonitorModel?.monitorItems ?? []);
    if (index < items.length) {
      items[index] = items[index].copyWith(
        upVoteCount: (items[index].upVoteCount ?? 0) + 1,
      );

      state = state.copyWith(
        productMonitorModel: state.productMonitorModel?.copyWith(
          monitorItems: items,
        ),
      );
    }
  }

  List<MonitorItemModel> _generateSampleData() {
    return [
      MonitorItemModel(
        date: "Thur, 23 Sept",
        time: "10:32:00 PM",
        productImage: ImageConstant.imgRectangle70,
        productTitle:
            "Magic:The Gathering | Avatar:The Last Airbender Collector Booster\ntarg",
        storeIcon: ImageConstant.imgEllipse10,
        storeName: "BestBuy",
        quantity: "N/A",
        price: "\$23.89",
        downVoteCount: 0,
        upVoteCount: 0,
      ),
      MonitorItemModel(
        date: "Thur, 23 Sept",
        time: "10:32:00 PM",
        productImage: ImageConstant.imgRectangle70,
        productTitle:
            "Magic:The Gathering | Avatar:The Last Airbender Collector Booster\ntarg",
        storeIcon: ImageConstant.imgEllipse11,
        storeName: "Amazon",
        quantity: "188",
        price: "\$23.89",
        downVoteCount: 0,
        upVoteCount: 99,
      ),
      MonitorItemModel(
        date: "Thur, 23 Sept",
        time: "10:32:00 PM",
        productImage: ImageConstant.imgRectangle70,
        productTitle:
            "Magic:The Gathering | Avatar:The Last Airbender Collector Booster\ntarg",
        storeIcon: ImageConstant.imgEllipse10,
        storeName: "Target",
        quantity: "67",
        price: "\$23.89",
        downVoteCount: 12,
        upVoteCount: 0,
      ),
    ];
  }

  @override
  void dispose() {
    state.searchController?.dispose();
    super.dispose();
  }
}
