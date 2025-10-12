import '../../../core/app_export.dart';

/// This class is used in the [NumberTypeFilterScreen] screen.

// ignore_for_file: must_be_immutable
class NumberTypeFilterModel extends Equatable {
  NumberTypeFilterModel({
    this.selectedFilter,
    this.isRestocksSelected,
    this.isReactionsSelected,
    this.id,
  }) {
    selectedFilter = selectedFilter ?? "restocks";
    isRestocksSelected = isRestocksSelected ?? true;
    isReactionsSelected = isReactionsSelected ?? false;
    id = id ?? "";
  }

  String? selectedFilter;
  bool? isRestocksSelected;
  bool? isReactionsSelected;
  String? id;

  NumberTypeFilterModel copyWith({
    String? selectedFilter,
    bool? isRestocksSelected,
    bool? isReactionsSelected,
    String? id,
  }) {
    return NumberTypeFilterModel(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isRestocksSelected: isRestocksSelected ?? this.isRestocksSelected,
      isReactionsSelected: isReactionsSelected ?? this.isReactionsSelected,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        selectedFilter,
        isRestocksSelected,
        isReactionsSelected,
        id,
      ];
}
