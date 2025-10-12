part of 'product_monitor_notifier.dart';

class ProductMonitorState extends Equatable {
  final TextEditingController? searchController;
  final String? searchQuery;
  final int? selectedTabIndex;
  final bool? isLoading;
  final ProductMonitorModel? productMonitorModel;

  ProductMonitorState({
    this.searchController,
    this.searchQuery,
    this.selectedTabIndex = 0,
    this.isLoading = false,
    this.productMonitorModel,
  });

  @override
  List<Object?> get props => [
        searchController,
        searchQuery,
        selectedTabIndex,
        isLoading,
        productMonitorModel,
      ];

  ProductMonitorState copyWith({
    TextEditingController? searchController,
    String? searchQuery,
    int? selectedTabIndex,
    bool? isLoading,
    ProductMonitorModel? productMonitorModel,
  }) {
    return ProductMonitorState(
      searchController: searchController ?? this.searchController,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isLoading: isLoading ?? this.isLoading,
      productMonitorModel: productMonitorModel ?? this.productMonitorModel,
    );
  }
}
