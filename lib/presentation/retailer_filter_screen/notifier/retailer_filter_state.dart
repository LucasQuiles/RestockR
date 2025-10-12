part of 'retailer_filter_notifier.dart';

class RetailerFilterState extends Equatable {
  final String? selectedFilter;
  final RetailerFilterModel? retailerFilterModel;
  final bool? isLoading;

  RetailerFilterState({
    this.selectedFilter,
    this.retailerFilterModel,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        selectedFilter,
        retailerFilterModel,
        isLoading,
      ];

  RetailerFilterState copyWith({
    String? selectedFilter,
    RetailerFilterModel? retailerFilterModel,
    bool? isLoading,
  }) {
    return RetailerFilterState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      retailerFilterModel: retailerFilterModel ?? this.retailerFilterModel,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
