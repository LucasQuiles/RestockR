import '../../../core/app_export.dart';

/// This class is used for category items in the [GlobalFilteringSettingsScreen] screen.

// ignore_for_file: must_be_immutable
class CategoryItemModel extends Equatable {
  CategoryItemModel({
    this.name,
    this.isEnabled,
    this.id,
  }) {
    name = name ?? "";
    isEnabled = isEnabled ?? false;
    id = id ?? "";
  }

  String? name;
  bool? isEnabled;
  String? id;

  CategoryItemModel copyWith({
    String? name,
    bool? isEnabled,
    String? id,
  }) {
    return CategoryItemModel(
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [name, isEnabled, id];
}
