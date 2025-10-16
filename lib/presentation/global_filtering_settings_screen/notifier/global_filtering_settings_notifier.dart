import 'package:flutter/material.dart';
import '../models/global_filtering_settings_model.dart';
import '../models/category_item_model.dart';
import '../../../core/app_export.dart';
import '../../../data/auth/auth_repository.dart';

part 'global_filtering_settings_state.dart';

final globalFilteringSettingsNotifier = StateNotifierProvider.autoDispose<
    GlobalFilteringSettingsNotifier, GlobalFilteringSettingsState>(
  (ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    return GlobalFilteringSettingsNotifier(
      GlobalFilteringSettingsState(
        globalFilteringSettingsModel: GlobalFilteringSettingsModel(),
      ),
      authRepository: authRepo,
    );
  },
);

class GlobalFilteringSettingsNotifier
    extends StateNotifier<GlobalFilteringSettingsState> {
  final AuthRepository _authRepository;

  GlobalFilteringSettingsNotifier(
    GlobalFilteringSettingsState state, {
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(state) {
    initialize();
  }

  Future<void> initialize() async {
    // Load current user preferences
    final userProfile = await _authRepository.getCurrentUser();

    if (userProfile != null) {
      // Map newSku to categories
      final categories = [
        CategoryItemModel(
          name: 'POKEMON',
          isEnabled: userProfile.newSku['pokemon'] ?? false,
        ),
        CategoryItemModel(
          name: 'MTG',
          isEnabled: userProfile.newSku['mtg'] ?? false,
        ),
        CategoryItemModel(
          name: 'OP',
          isEnabled: userProfile.newSku['op'] ?? false,
        ),
        CategoryItemModel(
          name: 'GUNDAM',
          isEnabled: userProfile.newSku['gundam'] ?? false,
        ),
        CategoryItemModel(
          name: 'RIFTBOUND',
          isEnabled: userProfile.newSku['riftbound'] ?? false,
        ),
        CategoryItemModel(
          name: 'YUGIOH',
          isEnabled: userProfile.newSku['yugioh'] ?? false,
        ),
      ];

      state = state.copyWith(
        minimumTargetController:
            TextEditingController(text: userProfile.minimumQty.toString()),
        globalFilteringSettingsModel:
            state.globalFilteringSettingsModel?.copyWith(
          categories: categories,
          minimumTarget: userProfile.minimumQty.toString(),
        ),
      );
    } else {
      // Use defaults
      final categories = [
        CategoryItemModel(name: 'POKEMON', isEnabled: false),
        CategoryItemModel(name: 'MTG', isEnabled: false),
        CategoryItemModel(name: 'OP', isEnabled: false),
        CategoryItemModel(name: 'GUNDAM', isEnabled: false),
        CategoryItemModel(name: 'RIFTBOUND', isEnabled: false),
        CategoryItemModel(name: 'YUGIOH', isEnabled: false),
      ];

      state = state.copyWith(
        minimumTargetController: TextEditingController(text: '1'),
        globalFilteringSettingsModel:
            state.globalFilteringSettingsModel?.copyWith(
          categories: categories,
          minimumTarget: '1',
        ),
      );
    }
  }

  Future<void> updateMinimumTarget(String value) async {
    // Update local state
    state = state.copyWith(
      globalFilteringSettingsModel:
          state.globalFilteringSettingsModel?.copyWith(
        minimumTarget: value,
      ),
    );

    // Parse and validate
    final qty = int.tryParse(value);
    if (qty == null || qty < 1) {
      print('⚠️ Invalid minimum quantity: $value');
      return;
    }

    // Persist to backend
    final success = await _authRepository.updateUserPreferences({
      'minimumQty': qty,
    });

    if (success) {
      print('✅ Minimum quantity updated: $qty');
    } else {
      print('❌ Failed to update minimum quantity');
    }
  }

  Future<void> toggleCategory(int index, bool value) async {
    final categories = List<CategoryItemModel>.from(
        state.globalFilteringSettingsModel?.categories ?? []);

    if (index < 0 || index >= categories.length) {
      return;
    }

    final categoryName = categories[index].name?.toLowerCase() ?? '';

    // Optimistically update UI
    categories[index] = categories[index].copyWith(isEnabled: value);

    state = state.copyWith(
      globalFilteringSettingsModel:
          state.globalFilteringSettingsModel?.copyWith(
        categories: categories,
      ),
    );

    // Build newSku map from all categories
    final newSkuMap = {
      for (var cat in categories)
        cat.name?.toLowerCase() ?? '': cat.isEnabled ?? false,
    };

    // Persist to backend
    final success = await _authRepository.updateUserPreferences({
      'newSku': newSkuMap,
    });

    if (!success) {
      // Revert on failure
      categories[index] = categories[index].copyWith(isEnabled: !value);

      state = state.copyWith(
        globalFilteringSettingsModel:
            state.globalFilteringSettingsModel?.copyWith(
          categories: categories,
        ),
      );
      print('❌ Failed to update category: $categoryName');
    } else {
      print('✅ Category updated: $categoryName = $value');
    }
  }

  @override
  void dispose() {
    state.minimumTargetController?.dispose();
    super.dispose();
  }
}
