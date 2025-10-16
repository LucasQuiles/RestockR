part of 'recheck_history_notifier.dart';

class RecheckHistoryState extends Equatable {
  final bool? isLoading;
  final RecheckHistoryModel? recheckHistoryModel;
  final ActivityItemModel? selectedActivityItem;
  final String? searchText;
  final bool? isLoadingDetails;
  final List<HistoryAlert>? historyDetails;
  final String? detailsError;
  /// Map of date (YYYY-MM-DD) to activity count for calendar heatmap
  final Map<String, int>? dailyActivityMap;

  RecheckHistoryState({
    this.isLoading = false,
    this.recheckHistoryModel,
    this.selectedActivityItem,
    this.searchText,
    this.isLoadingDetails = false,
    this.historyDetails,
    this.detailsError,
    this.dailyActivityMap,
  });

  @override
  List<Object?> get props => [
        isLoading,
        recheckHistoryModel,
        selectedActivityItem,
        searchText,
        isLoadingDetails,
        historyDetails,
        detailsError,
        dailyActivityMap,
      ];

  RecheckHistoryState copyWith({
    bool? isLoading,
    RecheckHistoryModel? recheckHistoryModel,
    ActivityItemModel? selectedActivityItem,
    String? searchText,
    bool? isLoadingDetails,
    List<HistoryAlert>? historyDetails,
    String? detailsError,
    Map<String, int>? dailyActivityMap,
  }) {
    return RecheckHistoryState(
      isLoading: isLoading ?? this.isLoading,
      recheckHistoryModel: recheckHistoryModel ?? this.recheckHistoryModel,
      selectedActivityItem: selectedActivityItem ?? this.selectedActivityItem,
      searchText: searchText ?? this.searchText,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      historyDetails: historyDetails ?? this.historyDetails,
      detailsError: detailsError ?? this.detailsError,
      dailyActivityMap: dailyActivityMap ?? this.dailyActivityMap,
    );
  }
}
