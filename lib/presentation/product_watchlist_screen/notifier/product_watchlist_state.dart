part of 'product_watchlist_notifier.dart';

class ProductWatchlistState extends Equatable {
  final ProductWatchlistModel? productWatchlistModel;
  final bool? isLoading;
  final int? selectedTabIndex;
  final String? searchQuery;

  ProductWatchlistState({
    this.productWatchlistModel,
    this.isLoading = false,
    this.selectedTabIndex = 0,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
        productWatchlistModel,
        isLoading,
        selectedTabIndex,
        searchQuery,
      ];

  ProductWatchlistState copyWith({
    ProductWatchlistModel? productWatchlistModel,
    bool? isLoading,
    int? selectedTabIndex,
    String? searchQuery,
  }) {
    return ProductWatchlistState(
      productWatchlistModel:
          productWatchlistModel ?? this.productWatchlistModel,
      isLoading: isLoading ?? this.isLoading,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
