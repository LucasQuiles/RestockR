import '../models/retailer_filter_model.dart';
import '../../../core/app_export.dart';

part 'retailer_filter_state.dart';

final retailerFilterNotifier = StateNotifierProvider.autoDispose<
    RetailerFilterNotifier, RetailerFilterState>(
  (ref) => RetailerFilterNotifier(
    RetailerFilterState(
      retailerFilterModel: RetailerFilterModel(),
    ),
  ),
);

class RetailerFilterNotifier extends StateNotifier<RetailerFilterState> {
  RetailerFilterNotifier(RetailerFilterState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      selectedFilter: 'Retailer',
      retailerFilterModel: RetailerFilterModel(
        amazonSelected: true,
        amazonUkSelected: false,
        costcoSelected: false,
        macysSelected: false,
        bestBuySelected: false,
        targetSelected: false,
        scheelsSelected: false,
        pokemonCenterSelected: false,
        walmartSelected: false,
      ),
    );
  }

  void selectFilter(String filterName) {
    state = state.copyWith(
      selectedFilter: filterName,
    );
  }

  void toggleRetailer(String retailerKey) {
    final currentModel = state.retailerFilterModel;
    RetailerFilterModel updatedModel;

    switch (retailerKey) {
      case 'amazon':
        updatedModel = currentModel?.copyWith(
              amazonSelected: !(currentModel.amazonSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'amazon-uk':
        updatedModel = currentModel?.copyWith(
              amazonUkSelected: !(currentModel.amazonUkSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'costco':
        updatedModel = currentModel?.copyWith(
              costcoSelected: !(currentModel.costcoSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'macys':
        updatedModel = currentModel?.copyWith(
              macysSelected: !(currentModel.macysSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'bestbuy':
        updatedModel = currentModel?.copyWith(
              bestBuySelected: !(currentModel.bestBuySelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'target':
        updatedModel = currentModel?.copyWith(
              targetSelected: !(currentModel.targetSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'scheels':
        updatedModel = currentModel?.copyWith(
              scheelsSelected: !(currentModel.scheelsSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'pokemon_center':
        updatedModel = currentModel?.copyWith(
              pokemonCenterSelected:
                  !(currentModel.pokemonCenterSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      case 'walmart':
        updatedModel = currentModel?.copyWith(
              walmartSelected: !(currentModel.walmartSelected ?? false),
            ) ??
            RetailerFilterModel();
        break;
      default:
        updatedModel = currentModel ?? RetailerFilterModel();
    }

    state = state.copyWith(
      retailerFilterModel: updatedModel,
    );
  }

  void clearAllFilters() {
    state = state.copyWith(
      retailerFilterModel: RetailerFilterModel(
        amazonSelected: false,
        amazonUkSelected: false,
        costcoSelected: false,
        macysSelected: false,
        bestBuySelected: false,
        targetSelected: false,
        scheelsSelected: false,
        pokemonCenterSelected: false,
        walmartSelected: false,
      ),
    );
  }

  void applyFilters() {
    // Logic to apply the selected filters
    // This could involve saving to preferences, making API calls, etc.
  }
}
