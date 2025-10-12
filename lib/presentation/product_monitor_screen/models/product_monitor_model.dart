import '../../../core/app_export.dart';
import './monitor_item_model.dart';

/// This class is used in the [product_monitor_screen] screen.

// ignore_for_file: must_be_immutable
class ProductMonitorModel extends Equatable {
  ProductMonitorModel({
    this.monitorItems,
  }) {
    monitorItems = monitorItems ?? [];
  }

  List<MonitorItemModel>? monitorItems;

  ProductMonitorModel copyWith({
    List<MonitorItemModel>? monitorItems,
  }) {
    return ProductMonitorModel(
      monitorItems: monitorItems ?? this.monitorItems,
    );
  }

  @override
  List<Object?> get props => [monitorItems];
}
