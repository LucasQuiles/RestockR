import '../models/number_type_filter_model.dart';
import '../../../core/app_export.dart';

part 'number_type_filter_state.dart';

final numberTypeFilterNotifier = StateNotifierProvider.autoDispose<
    NumberTypeFilterNotifier, NumberTypeFilterState>(
  (ref) => NumberTypeFilterNotifier(
    NumberTypeFilterState(
      numberTypeFilterModel: NumberTypeFilterModel(),
    ),
  ),
);

class NumberTypeFilterNotifier extends StateNotifier<NumberTypeFilterState> {
  NumberTypeFilterNotifier(NumberTypeFilterState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      selectedNumberType: 'restocks',
      isFiltersApplied: false,
    );
  }

  void selectNumberType(String numberType) {
    state = state.copyWith(
      selectedNumberType: numberType,
    );
  }

  void clearAllFilters() {
    state = state.copyWith(
      selectedNumberType: null,
      isFiltersApplied: false,
    );
  }

  void applyFilters() {
    state = state.copyWith(
      isFiltersApplied: true,
    );
  }
}
