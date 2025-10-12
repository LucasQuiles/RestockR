import '../../../core/app_export.dart';

/// This class is used in the [retailer_filter_screen] screen.

// ignore_for_file: must_be_immutable
class RetailerFilterModel extends Equatable {
  RetailerFilterModel({
    this.amazonSelected,
    this.amazonUkSelected,
    this.costcoSelected,
    this.macysSelected,
    this.bestBuySelected,
    this.targetSelected,
    this.scheelsSelected,
    this.pokemonCenterSelected,
    this.walmartSelected,
  }) {
    amazonSelected = amazonSelected ?? false;
    amazonUkSelected = amazonUkSelected ?? false;
    costcoSelected = costcoSelected ?? false;
    macysSelected = macysSelected ?? false;
    bestBuySelected = bestBuySelected ?? false;
    targetSelected = targetSelected ?? false;
    scheelsSelected = scheelsSelected ?? false;
    pokemonCenterSelected = pokemonCenterSelected ?? false;
    walmartSelected = walmartSelected ?? false;
  }

  bool? amazonSelected;
  bool? amazonUkSelected;
  bool? costcoSelected;
  bool? macysSelected;
  bool? bestBuySelected;
  bool? targetSelected;
  bool? scheelsSelected;
  bool? pokemonCenterSelected;
  bool? walmartSelected;

  RetailerFilterModel copyWith({
    bool? amazonSelected,
    bool? amazonUkSelected,
    bool? costcoSelected,
    bool? macysSelected,
    bool? bestBuySelected,
    bool? targetSelected,
    bool? scheelsSelected,
    bool? pokemonCenterSelected,
    bool? walmartSelected,
  }) {
    return RetailerFilterModel(
      amazonSelected: amazonSelected ?? this.amazonSelected,
      amazonUkSelected: amazonUkSelected ?? this.amazonUkSelected,
      costcoSelected: costcoSelected ?? this.costcoSelected,
      macysSelected: macysSelected ?? this.macysSelected,
      bestBuySelected: bestBuySelected ?? this.bestBuySelected,
      targetSelected: targetSelected ?? this.targetSelected,
      scheelsSelected: scheelsSelected ?? this.scheelsSelected,
      pokemonCenterSelected:
          pokemonCenterSelected ?? this.pokemonCenterSelected,
      walmartSelected: walmartSelected ?? this.walmartSelected,
    );
  }

  @override
  List<Object?> get props => [
        amazonSelected,
        amazonUkSelected,
        costcoSelected,
        macysSelected,
        bestBuySelected,
        targetSelected,
        scheelsSelected,
        pokemonCenterSelected,
        walmartSelected,
      ];
}
