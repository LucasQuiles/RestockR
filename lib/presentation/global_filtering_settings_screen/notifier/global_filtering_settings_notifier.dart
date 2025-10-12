import 'package:flutter/material.dart';
import '../models/global_filtering_settings_model.dart';
import '../models/category_item_model.dart';
import '../../../core/app_export.dart';

part 'global_filtering_settings_state.dart';

final globalFilteringSettingsNotifier = StateNotifierProvider.autoDispose<
    GlobalFilteringSettingsNotifier, GlobalFilteringSettingsState>(
  (ref) => GlobalFilteringSettingsNotifier(
    GlobalFilteringSettingsState(
      globalFilteringSettingsModel: GlobalFilteringSettingsModel(),
    ),
  ),
);

class GlobalFilteringSettingsNotifier
    extends StateNotifier<GlobalFilteringSettingsState> {
  GlobalFilteringSettingsNotifier(GlobalFilteringSettingsState state)
      : super(state) {
    initialize();
  }

  void initialize() {
    final categories = [
      CategoryItemModel(name: 'POKEMON', isEnabled: true),
      CategoryItemModel(name: 'MTG', isEnabled: true),
      CategoryItemModel(name: 'OP', isEnabled: true),
      CategoryItemModel(name: 'GUNDAM', isEnabled: true),
      CategoryItemModel(name: 'RIFTBOUND', isEnabled: true),
      CategoryItemModel(name: 'YUGIOH', isEnabled: true),
    ];

    state = state.copyWith(
      minimumTargetController: TextEditingController(text: '12'),
      globalFilteringSettingsModel:
          state.globalFilteringSettingsModel?.copyWith(
        categories: categories,
        minimumTarget: '12',
      ),
    );
  }

  void updateMinimumTarget(String value) {
    state = state.copyWith(
      globalFilteringSettingsModel:
          state.globalFilteringSettingsModel?.copyWith(
        minimumTarget: value,
      ),
    );
  }

  void toggleCategory(int index, bool value) {
    final categories = List<CategoryItemModel>.from(
        state.globalFilteringSettingsModel?.categories ?? []);

    if (index < categories.length) {
      categories[index] = categories[index].copyWith(isEnabled: value);

      state = state.copyWith(
        globalFilteringSettingsModel:
            state.globalFilteringSettingsModel?.copyWith(
          categories: categories,
        ),
      );
    }
  }

  @override
  void dispose() {
    state.minimumTargetController?.dispose();
    super.dispose();
  }
}
