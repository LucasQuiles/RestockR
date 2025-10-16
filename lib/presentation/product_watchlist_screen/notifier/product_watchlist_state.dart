part of 'product_watchlist_notifier.dart';

class ProductWatchlistState extends Equatable {
  final ProductWatchlistModel? productWatchlistModel;
  final bool? isLoading;
  final int? selectedTabIndex;
  final String? searchQuery;
  final int? subscribedCount;
  final bool? hasError;
  final String? errorMessage;

  ProductWatchlistState({
    this.productWatchlistModel,
    this.isLoading = false,
    this.selectedTabIndex = 0,
    this.searchQuery = '',
    this.subscribedCount = 0,
    this.hasError = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        productWatchlistModel,
        isLoading,
        selectedTabIndex,
        searchQuery,
        subscribedCount,
        hasError,
        errorMessage,
      ];

  ProductWatchlistState copyWith({
    ProductWatchlistModel? productWatchlistModel,
    bool? isLoading,
    int? selectedTabIndex,
    String? searchQuery,
    int? subscribedCount,
    bool? hasError,
    String? errorMessage,
  }) {
    return ProductWatchlistState(
      productWatchlistModel:
          productWatchlistModel ?? this.productWatchlistModel,
      isLoading: isLoading ?? this.isLoading,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      subscribedCount: subscribedCount ?? this.subscribedCount,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
