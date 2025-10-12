import '../../../core/app_export.dart';
import './category_item_model.dart';

/// This class is used in the [GlobalFilteringSettingsScreen] screen.

// ignore_for_file: must_be_immutable
class GlobalFilteringSettingsModel extends Equatable {
  GlobalFilteringSettingsModel({
    this.minimumTarget,
    this.categories,
    this.id,
  }) {
    minimumTarget = minimumTarget ?? "12";
    categories = categories ?? [];
    id = id ?? "";
  }

  String? minimumTarget;
  List<CategoryItemModel>? categories;
  String? id;

  GlobalFilteringSettingsModel copyWith({
    String? minimumTarget,
    List<CategoryItemModel>? categories,
    String? id,
  }) {
    return GlobalFilteringSettingsModel(
      minimumTarget: minimumTarget ?? this.minimumTarget,
      categories: categories ?? this.categories,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [minimumTarget, categories, id];
}
