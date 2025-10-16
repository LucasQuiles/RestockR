import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../core/data_providers.dart';
import '../../../data/restocks/restock_feed_repository.dart';
import '../../../data/restocks/models/restock_alert.dart';
import '../models/monitor_item_model.dart';
import '../models/product_monitor_model.dart';

part 'product_monitor_state.dart';

final productMonitorNotifier = StateNotifierProvider.autoDispose<
    ProductMonitorNotifier, ProductMonitorState>(
  (ref) {
    final repository = ref.watch(restockFeedRepositoryProvider);
    return ProductMonitorNotifier(
      ProductMonitorState(
        productMonitorModel: ProductMonitorModel(),
      ),
      repository: repository,
    );
  },
);

class ProductMonitorNotifier extends StateNotifier<ProductMonitorState> {
  final RestockFeedRepository _repository;
  final Map<int, String> _indexToAlertId = {}; // Maps UI index to alert ID

  ProductMonitorNotifier(
    ProductMonitorState state, {
    required RestockFeedRepository repository,
  })  : _repository = repository,
        super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      searchController: TextEditingController(),
      selectedTabIndex: 0,
      isLoading: true,
    );
    loadAlerts();
  }

  /// Load recent alerts from repository
  Future<void> loadAlerts() async {
    state = state.copyWith(isLoading: true, hasError: false);

    final result = await _repository.getRecentAlerts(limit: 25);

    if (result.isSuccess) {
      final monitorItems = _convertAlertsToMonitorItems(result.alerts);
      state = state.copyWith(
        isLoading: false,
        productMonitorModel: ProductMonitorModel(monitorItems: monitorItems),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: result.error ?? 'Failed to load alerts',
      );
    }
  }

  /// Convert RestockAlert list to MonitorItemModel list
  List<MonitorItemModel> _convertAlertsToMonitorItems(
      List<RestockAlert> alerts) {
    _indexToAlertId.clear();

    final items = <MonitorItemModel>[];
    for (int i = 0; i < alerts.length; i++) {
      final alert = alerts[i];
      _indexToAlertId[i] = alert.id;

      items.add(MonitorItemModel(
        date: DateFormat('E, dd MMM').format(alert.timestamp),
        time: DateFormat('hh:mm:ss a').format(alert.timestamp),
        productImage: alert.image ?? ImageConstant.imgRectangle70,
        productTitle: alert.product,
        storeIcon: _getStoreIcon(alert.store),
        storeName: alert.store,
        quantity: 'N/A', // Backend doesn't provide quantity yet
        price: alert.price ?? 'N/A',
        downVoteCount: alert.reactions.no,
        upVoteCount: alert.reactions.yes,
      ));
    }

    return items;
  }

  /// Get store icon based on store name
  String _getStoreIcon(String store) {
    final storeLower = store.toLowerCase();
    if (storeLower.contains('bestbuy')) return ImageConstant.imgEllipse10;
    if (storeLower.contains('amazon')) return ImageConstant.imgEllipse11;
    if (storeLower.contains('target')) return ImageConstant.imgEllipse10;
    return ImageConstant.imgEllipse10; // Default icon
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

  /// Submit downvote reaction
  Future<void> onDownVote(int index) async {
    final alertId = _indexToAlertId[index];
    if (alertId == null) return;

    // Optimistically update UI
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

      // Submit to backend
      final success = await _repository.submitReaction(alertId, false);
      if (!success) {
        // Revert optimistic update on failure
        items[index] = items[index].copyWith(
          downVoteCount: (items[index].downVoteCount ?? 1) - 1,
        );
        state = state.copyWith(
          productMonitorModel: state.productMonitorModel?.copyWith(
            monitorItems: items,
          ),
        );
      }
    }
  }

  /// Submit upvote reaction
  Future<void> onUpVote(int index) async {
    final alertId = _indexToAlertId[index];
    if (alertId == null) return;

    // Optimistically update UI
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

      // Submit to backend
      final success = await _repository.submitReaction(alertId, true);
      if (!success) {
        // Revert optimistic update on failure
        items[index] = items[index].copyWith(
          upVoteCount: (items[index].upVoteCount ?? 1) - 1,
        );
        state = state.copyWith(
          productMonitorModel: state.productMonitorModel?.copyWith(
            monitorItems: items,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    state.searchController?.dispose();
    super.dispose();
  }
}
