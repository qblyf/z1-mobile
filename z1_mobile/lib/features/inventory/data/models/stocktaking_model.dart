import 'package:equatable/equatable.dart';

enum StocktakingState {
  draft(0, '草稿'),
  inProgress(1, '进行中'),
  completed(2, '已完成'),
  approved(3, '已审核');

  final int value;
  final String label;
  const StocktakingState(this.value, this.label);

  static StocktakingState fromInt(int? value) {
    switch (value) {
      case 1:
        return StocktakingState.inProgress;
      case 2:
        return StocktakingState.completed;
      case 3:
        return StocktakingState.approved;
      default:
        return StocktakingState.draft;
    }
  }
}

class StocktakingModel extends Equatable {
  final int id;
  final String? code;
  final int warehouseID;
  final String? warehouseName;
  final StocktakingState state;
  final int createdAt;
  final int? submittedAt;
  final int? approvedAt;
  final int createdBy;
  final String? remarks;

  const StocktakingModel({
    required this.id,
    this.code,
    required this.warehouseID,
    this.warehouseName,
    required this.state,
    required this.createdAt,
    this.submittedAt,
    this.approvedAt,
    required this.createdBy,
    this.remarks,
  });

  factory StocktakingModel.fromJson(Map<String, dynamic> json) {
    return StocktakingModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      warehouseID: json['warehouseID'] as int? ?? 0,
      warehouseName: json['warehouseName'] as String?,
      state: StocktakingState.fromInt(json['state'] as int?),
      createdAt: json['createdAt'] as int? ?? 0,
      submittedAt: json['submittedAt'] as int?,
      approvedAt: json['approvedAt'] as int?,
      createdBy: json['createdBy'] as int? ?? 0,
      remarks: json['remarks'] as String?,
    );
  }

  String get stateLabel => state.label;

  String get timeAgo {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - createdAt;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return '${diff ~/ 60}分钟前';
    if (diff < 86400) return '${diff ~/ 3600}小时前';
    return '${diff ~/ 86400}天前';
  }

  @override
  List<Object?> get props => [id, code, warehouseID, state, createdAt];
}

class StocktakingProductModel extends Equatable {
  final int productId;
  final String productName;
  final String? spec;
  final String? barcode;
  final int systemQty;
  final int actualQty;
  final int? difference;

  const StocktakingProductModel({
    required this.productId,
    required this.productName,
    this.spec,
    this.barcode,
    required this.systemQty,
    required this.actualQty,
    this.difference,
  });

  factory StocktakingProductModel.fromJson(Map<String, dynamic> json) {
    return StocktakingProductModel(
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      spec: json['spec'] as String?,
      barcode: json['barcode'] as String?,
      systemQty: json['systemQty'] as int? ?? 0,
      actualQty: json['actualQty'] as int? ?? 0,
      difference: json['difference'] as int?,
    );
  }

  int get diff => difference ?? (actualQty - systemQty);

  @override
  List<Object?> get props => [productId, productName, systemQty, actualQty];
}

class WarehouseModel extends Equatable {
  final int id;
  final String name;
  final String? number;

  const WarehouseModel({
    required this.id,
    required this.name,
    this.number,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      number: json['number'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}