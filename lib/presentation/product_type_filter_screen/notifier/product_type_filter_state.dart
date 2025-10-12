part of 'product_type_filter_notifier.dart';

class ProductTypeFilterState extends Equatable {
  final ProductTypeFilterModel? productTypeFilterModel;

  ProductTypeFilterState({
    this.productTypeFilterModel,
  });

  @override
  List<Object?> get props => [
        productTypeFilterModel,
      ];

  ProductTypeFilterState copyWith({
    ProductTypeFilterModel? productTypeFilterModel,
  }) {
    return ProductTypeFilterState(
      productTypeFilterModel:
          productTypeFilterModel ?? this.productTypeFilterModel,
    );
  }
}
