import '../../../core/app_export.dart';

/// This class is used in the [ProductTypeFilterScreen] screen.

// ignore_for_file: must_be_immutable
class ProductTypeFilterModel extends Equatable {
  ProductTypeFilterModel({
    this.allTypeSelected,
    this.pokemonSelected,
    this.onepieceSelected,
    this.yugoMtgSelected,
    this.gundamSelected,
    this.sportscardsSelected,
    this.scheelsSelected,
    this.pokemonCenterSelected,
    this.walmartSelected,
  }) {
    allTypeSelected = allTypeSelected ?? false;
    pokemonSelected = pokemonSelected ?? true;
    onepieceSelected = onepieceSelected ?? false;
    yugoMtgSelected = yugoMtgSelected ?? false;
    gundamSelected = gundamSelected ?? false;
    sportscardsSelected = sportscardsSelected ?? false;
    scheelsSelected = scheelsSelected ?? false;
    pokemonCenterSelected = pokemonCenterSelected ?? false;
    walmartSelected = walmartSelected ?? false;
  }

  bool? allTypeSelected;
  bool? pokemonSelected;
  bool? onepieceSelected;
  bool? yugoMtgSelected;
  bool? gundamSelected;
  bool? sportscardsSelected;
  bool? scheelsSelected;
  bool? pokemonCenterSelected;
  bool? walmartSelected;

  ProductTypeFilterModel copyWith({
    bool? allTypeSelected,
    bool? pokemonSelected,
    bool? onepieceSelected,
    bool? yugoMtgSelected,
    bool? gundamSelected,
    bool? sportscardsSelected,
    bool? scheelsSelected,
    bool? pokemonCenterSelected,
    bool? walmartSelected,
  }) {
    return ProductTypeFilterModel(
      allTypeSelected: allTypeSelected ?? this.allTypeSelected,
      pokemonSelected: pokemonSelected ?? this.pokemonSelected,
      onepieceSelected: onepieceSelected ?? this.onepieceSelected,
      yugoMtgSelected: yugoMtgSelected ?? this.yugoMtgSelected,
      gundamSelected: gundamSelected ?? this.gundamSelected,
      sportscardsSelected: sportscardsSelected ?? this.sportscardsSelected,
      scheelsSelected: scheelsSelected ?? this.scheelsSelected,
      pokemonCenterSelected:
          pokemonCenterSelected ?? this.pokemonCenterSelected,
      walmartSelected: walmartSelected ?? this.walmartSelected,
    );
  }

  @override
  List<Object?> get props => [
        allTypeSelected,
        pokemonSelected,
        onepieceSelected,
        yugoMtgSelected,
        gundamSelected,
        sportscardsSelected,
        scheelsSelected,
        pokemonCenterSelected,
        walmartSelected,
      ];
}
