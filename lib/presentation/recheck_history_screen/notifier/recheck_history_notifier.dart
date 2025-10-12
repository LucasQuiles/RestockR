import '../models/recheck_history_model.dart';
import '../../../core/app_export.dart';

part 'recheck_history_state.dart';

final recheckHistoryNotifier = StateNotifierProvider.autoDispose<
    RecheckHistoryNotifier, RecheckHistoryState>(
  (ref) => RecheckHistoryNotifier(
    RecheckHistoryState(
      recheckHistoryModel: RecheckHistoryModel(),
    ),
  ),
);

class RecheckHistoryNotifier extends StateNotifier<RecheckHistoryState> {
  RecheckHistoryNotifier(RecheckHistoryState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      isLoading: false,
      recheckHistoryModel: RecheckHistoryModel(),
    );
  }

  void onMonthChanged(String month) {
    final updatedModel = state.recheckHistoryModel?.copyWith(
      selectedMonth: month,
    );

    state = state.copyWith(
      recheckHistoryModel: updatedModel,
    );
  }

  void onDateChanged(DateTime date) {
    final updatedModel = state.recheckHistoryModel?.copyWith(
      selectedDate: date,
    );

    state = state.copyWith(
      recheckHistoryModel: updatedModel,
    );
  }

  void onActivityItemTapped(ActivityItemModel item) {
    // Handle activity item selection logic
    state = state.copyWith(
      selectedActivityItem: item,
    );
  }

  void onSearchChanged(String searchText) {
    state = state.copyWith(
      searchText: searchText,
    );
  }

  void refreshData() {
    state = state.copyWith(isLoading: true);

    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      state = state.copyWith(
        isLoading: false,
        recheckHistoryModel: RecheckHistoryModel(),
      );
    });
  }
}
