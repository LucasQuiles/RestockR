part of 'recheck_history_notifier.dart';

class RecheckHistoryState extends Equatable {
  final bool? isLoading;
  final RecheckHistoryModel? recheckHistoryModel;
  final ActivityItemModel? selectedActivityItem;
  final String? searchText;

  RecheckHistoryState({
    this.isLoading = false,
    this.recheckHistoryModel,
    this.selectedActivityItem,
    this.searchText,
  });

  @override
  List<Object?> get props => [
        isLoading,
        recheckHistoryModel,
        selectedActivityItem,
        searchText,
      ];

  RecheckHistoryState copyWith({
    bool? isLoading,
    RecheckHistoryModel? recheckHistoryModel,
    ActivityItemModel? selectedActivityItem,
    String? searchText,
  }) {
    return RecheckHistoryState(
      isLoading: isLoading ?? this.isLoading,
      recheckHistoryModel: recheckHistoryModel ?? this.recheckHistoryModel,
      selectedActivityItem: selectedActivityItem ?? this.selectedActivityItem,
      searchText: searchText ?? this.searchText,
    );
  }
}
