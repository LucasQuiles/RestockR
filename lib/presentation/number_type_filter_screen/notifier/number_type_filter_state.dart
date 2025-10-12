part of 'number_type_filter_notifier.dart';

class NumberTypeFilterState extends Equatable {
  final String? selectedNumberType;
  final bool? isFiltersApplied;
  final NumberTypeFilterModel? numberTypeFilterModel;

  NumberTypeFilterState({
    this.selectedNumberType,
    this.isFiltersApplied = false,
    this.numberTypeFilterModel,
  });

  @override
  List<Object?> get props => [
        selectedNumberType,
        isFiltersApplied,
        numberTypeFilterModel,
      ];

  NumberTypeFilterState copyWith({
    String? selectedNumberType,
    bool? isFiltersApplied,
    NumberTypeFilterModel? numberTypeFilterModel,
  }) {
    return NumberTypeFilterState(
      selectedNumberType: selectedNumberType ?? this.selectedNumberType,
      isFiltersApplied: isFiltersApplied ?? this.isFiltersApplied,
      numberTypeFilterModel:
          numberTypeFilterModel ?? this.numberTypeFilterModel,
    );
  }
}
