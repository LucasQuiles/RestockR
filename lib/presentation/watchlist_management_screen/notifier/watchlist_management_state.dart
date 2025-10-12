part of 'watchlist_management_notifier.dart';

class WatchlistManagementState extends Equatable {
  final bool? isLoading;
  final bool? isUnsubscribeSuccess;
  final String? unsubscribedItemId;
  final WatchlistManagementModel? watchlistManagementModel;

  WatchlistManagementState({
    this.isLoading = false,
    this.isUnsubscribeSuccess = false,
    this.unsubscribedItemId,
    this.watchlistManagementModel,
  });

  @override
  List<Object?> get props => [
        isLoading,
        isUnsubscribeSuccess,
        unsubscribedItemId,
        watchlistManagementModel,
      ];

  WatchlistManagementState copyWith({
    bool? isLoading,
    bool? isUnsubscribeSuccess,
    String? unsubscribedItemId,
    WatchlistManagementModel? watchlistManagementModel,
  }) {
    return WatchlistManagementState(
      isLoading: isLoading ?? this.isLoading,
      isUnsubscribeSuccess: isUnsubscribeSuccess ?? this.isUnsubscribeSuccess,
      unsubscribedItemId: unsubscribedItemId ?? this.unsubscribedItemId,
      watchlistManagementModel:
          watchlistManagementModel ?? this.watchlistManagementModel,
    );
  }
}
