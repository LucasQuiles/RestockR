part of 'watchlist_management_notifier.dart';

class WatchlistManagementState extends Equatable {
  final bool? isLoading;
  final bool? hasError;
  final String? errorMessage;
  final bool? isUnsubscribeSuccess;
  final String? unsubscribedItemId;
  final WatchlistManagementModel? watchlistManagementModel;

  WatchlistManagementState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.isUnsubscribeSuccess = false,
    this.unsubscribedItemId,
    this.watchlistManagementModel,
  });

  @override
  List<Object?> get props => [
        isLoading,
        hasError,
        errorMessage,
        isUnsubscribeSuccess,
        unsubscribedItemId,
        watchlistManagementModel,
      ];

  WatchlistManagementState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isUnsubscribeSuccess,
    String? unsubscribedItemId,
    WatchlistManagementModel? watchlistManagementModel,
  }) {
    return WatchlistManagementState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isUnsubscribeSuccess: isUnsubscribeSuccess ?? this.isUnsubscribeSuccess,
      unsubscribedItemId: unsubscribedItemId ?? this.unsubscribedItemId,
      watchlistManagementModel:
          watchlistManagementModel ?? this.watchlistManagementModel,
    );
  }
}
