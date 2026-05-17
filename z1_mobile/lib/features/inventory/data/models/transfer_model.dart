import 'package:equatable/equatable.dart';

enum TransferState {
  pending(0, '待发货'),
  shipping(1, '待入库'),
  completed(2, '已完成');

  final int value;
  final String label;
  const TransferState(this.value, this.label);

  static TransferState fromInt(int? value) {
    switch (value) {
      case 1:
        return TransferState.shipping;
      case 2:
        return TransferState.completed;
      default:
        return TransferState.pending;
    }
  }
}

class TransferModel extends Equatable {
  final int id;
  final String? code;
  final int fromWarehouseID;
  final String? fromWarehouseName;
  final int toWarehouseID;
  final String? toWarehouseName;
  final TransferState state;
  final int createdAt;
  final int createdBy;
  final int productCount;

  const TransferModel({
    required this.id,
    this.code,
    required this.fromWarehouseID,
    this.fromWarehouseName,
    required this.toWarehouseID,
    this.toWarehouseName,
    required this.state,
    required this.createdAt,
    required this.createdBy,
    this.productCount = 0,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      fromWarehouseID: json['fromWarehouseID'] as int? ?? 0,
      fromWarehouseName: json['fromWarehouseName'] as String?,
      toWarehouseID: json['toWarehouseID'] as int? ?? 0,
      toWarehouseName: json['toWarehouseName'] as String?,
      state: TransferState.fromInt(json['state'] as int?),
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as int? ?? 0,
      productCount: json['productCount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, code, fromWarehouseID, toWarehouseID, state, createdAt];
}