import 'package:equatable/equatable.dart';

class SerialSearchResultModel extends Equatable {
  final int productId;
  final String productName;
  final String? spec;
  final String? barcode;
  final String? serialNumber;
  final String? categoryName;
  final WarehouseLocationModel? location;
  final List<StockFlowModel> stockFlows;

  const SerialSearchResultModel({
    required this.productId,
    required this.productName,
    this.spec,
    this.barcode,
    this.serialNumber,
    this.categoryName,
    this.location,
    this.stockFlows = const [],
  });

  factory SerialSearchResultModel.fromJson(Map<String, dynamic> json) {
    return SerialSearchResultModel(
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      spec: json['spec'] as String?,
      barcode: json['barcode'] as String?,
      serialNumber: json['serialNumber'] as String?,
      categoryName: json['categoryName'] as String?,
      location: json['location'] != null
          ? WarehouseLocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      stockFlows: (json['stockFlows'] as List<dynamic>?)
              ?.map((e) => StockFlowModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [productId, productName, serialNumber];
}

class WarehouseLocationModel extends Equatable {
  final int warehouseId;
  final String? warehouseName;
  final String? cabinetPosition;

  const WarehouseLocationModel({
    required this.warehouseId,
    this.warehouseName,
    this.cabinetPosition,
  });

  factory WarehouseLocationModel.fromJson(Map<String, dynamic> json) {
    return WarehouseLocationModel(
      warehouseId: json['warehouseId'] as int? ?? 0,
      warehouseName: json['warehouseName'] as String?,
      cabinetPosition: json['cabinetPosition'] as String?,
    );
  }

  @override
  List<Object?> get props => [warehouseId, cabinetPosition];
}

class StockFlowModel extends Equatable {
  final int id;
  final String? orderNumber;
  final String flowType;
  final int quantity;
  final int flowTime;
  final String? fromWarehouseName;
  final String? toWarehouseName;

  const StockFlowModel({
    required this.id,
    this.orderNumber,
    required this.flowType,
    required this.quantity,
    required this.flowTime,
    this.fromWarehouseName,
    this.toWarehouseName,
  });

  factory StockFlowModel.fromJson(Map<String, dynamic> json) {
    return StockFlowModel(
      id: json['id'] as int? ?? 0,
      orderNumber: json['orderNumber'] as String?,
      flowType: json['flowType'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      flowTime: json['flowTime'] as int? ?? 0,
      fromWarehouseName: json['fromWarehouseName'] as String?,
      toWarehouseName: json['toWarehouseName'] as String?,
    );
  }

  String get flowTypeLabel {
    switch (flowType) {
      case 'in':
        return '入库';
      case 'out':
        return '出库';
      case 'transfer':
        return '调拨';
      default:
        return flowType;
    }
  }

  @override
  List<Object?> get props => [id, flowType, flowTime];
}