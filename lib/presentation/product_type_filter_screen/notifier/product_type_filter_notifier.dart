import '../models/product_type_filter_model.dart';
import '../../../core/app_export.dart';

part 'product_type_filter_state.dart';

final productTypeFilterNotifier = StateNotifierProvider.autoDispose<
    ProductTypeFilterNotifier, ProductTypeFilterState>(
  (ref) => ProductTypeFilterNotifier(
    ProductTypeFilterState(
      productTypeFilterModel: ProductTypeFilterModel(),
    ),
  ),
);

class ProductTypeFilterNotifier extends StateNotifier<ProductTypeFilterState> {
  ProductTypeFilterNotifier(ProductTypeFilterState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      productTypeFilterModel: ProductTypeFilterModel(
        allTypeSelected: false,
        pokemonSelected: true, // Based on the design, Pokemon is pre-selected
        onepieceSelected: false,
        yugoMtgSelected: false,
        gundamSelected: false,
        sportscardsSelected: false,
        scheelsSelected: false,
        pokemonCenterSelected: false,
        walmartSelected: false,
      ),
    );
  }

  void toggleAllType() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        allTypeSelected: !(currentModel.allTypeSelected ?? false),
      ),
    );
  }

  void togglePokemon() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        pokemonSelected: !(currentModel.pokemonSelected ?? false),
      ),
    );
  }

  void toggleOnepiece() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        onepieceSelected: !(currentModel.onepieceSelected ?? false),
      ),
    );
  }

  void toggleYugoMtg() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        yugoMtgSelected: !(currentModel.yugoMtgSelected ?? false),
      ),
    );
  }

  void toggleGundam() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        gundamSelected: !(currentModel.gundamSelected ?? false),
      ),
    );
  }

  void toggleSportscards() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        sportscardsSelected: !(currentModel.sportscardsSelected ?? false),
      ),
    );
  }

  void toggleScheels() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        scheelsSelected: !(currentModel.scheelsSelected ?? false),
      ),
    );
  }

  void togglePokemonCenter() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        pokemonCenterSelected: !(currentModel.pokemonCenterSelected ?? false),
      ),
    );
  }

  void toggleWalmart() {
    final currentModel = state.productTypeFilterModel;
    state = state.copyWith(
      productTypeFilterModel: currentModel?.copyWith(
        walmartSelected: !(currentModel.walmartSelected ?? false),
      ),
    );
  }

  void clearAllFilters() {
    state = state.copyWith(
      productTypeFilterModel: ProductTypeFilterModel(
        allTypeSelected: false,
        pokemonSelected: false,
        onepieceSelected: false,
        yugoMtgSelected: false,
        gundamSelected: false,
        sportscardsSelected: false,
        scheelsSelected: false,
        pokemonCenterSelected: false,
        walmartSelected: false,
      ),
    );
  }

  void applyFilters() {
    // Here you can add logic to save the filter preferences
    // or perform any action when filters are applied
    // For now, we'll just keep the current state
  }
}
