import '../models/watchlist_management_model.dart';
import '../../../core/app_export.dart';

part 'watchlist_management_state.dart';

final watchlistManagementNotifier = StateNotifierProvider.autoDispose<
    WatchlistManagementNotifier, WatchlistManagementState>(
  (ref) => WatchlistManagementNotifier(
    WatchlistManagementState(
      watchlistManagementModel: WatchlistManagementModel(),
    ),
  ),
);

class WatchlistManagementNotifier
    extends StateNotifier<WatchlistManagementState> {
  WatchlistManagementNotifier(WatchlistManagementState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      isLoading: false,
    );
  }

  void onUnsubscribe(String itemId) {
    state = state.copyWith(isLoading: true);

    // Simulate unsubscribe process
    Future.delayed(Duration(milliseconds: 500), () {
      final updatedItems = state.watchlistManagementModel?.subscriptionItems
          ?.where((item) => item.id != itemId)
          .toList();

      final updatedModel = state.watchlistManagementModel?.copyWith(
        subscriptionItems: updatedItems,
      );

      state = state.copyWith(
        watchlistManagementModel: updatedModel,
        isLoading: false,
        isUnsubscribeSuccess: true,
        unsubscribedItemId: itemId,
      );
    });
  }

  void resetUnsubscribeState() {
    state = state.copyWith(
      isUnsubscribeSuccess: false,
      unsubscribedItemId: null,
    );
  }
}
