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

class TransferDetailModel extends Equatable {
  final int id;
  final String? code;
  final int fromWarehouseID;
  final String? fromWarehouseName;
  final int toWarehouseID;
  final String? toWarehouseName;
  final TransferState state;
  final int createdAt;
  final int createdBy;
  final String? creatorName;
  final int? shippedAt;
  final int? receivedAt;
  final List<TransferGoodsItem> goodsInfo;

  const TransferDetailModel({
    required this.id,
    this.code,
    required this.fromWarehouseID,
    this.fromWarehouseName,
    required this.toWarehouseID,
    this.toWarehouseName,
    required this.state,
    required this.createdAt,
    required this.createdBy,
    this.creatorName,
    this.shippedAt,
    this.receivedAt,
    this.goodsInfo = const [],
  });

  factory TransferDetailModel.fromJson(Map<String, dynamic> json) {
    return TransferDetailModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      fromWarehouseID: json['fromWarehouseID'] as int? ?? 0,
      fromWarehouseName: json['fromWarehouseName'] as String?,
      toWarehouseID: json['toWarehouseID'] as int? ?? 0,
      toWarehouseName: json['toWarehouseName'] as String?,
      state: TransferState.fromInt(json['state'] as int?),
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as int? ?? 0,
      creatorName: json['creatorName'] as String?,
      shippedAt: json['shippedAt'] as int?,
      receivedAt: json['receivedAt'] as int?,
      goodsInfo: (json['goodsInfo'] as List<dynamic>?)
              ?.map((e) => TransferGoodsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, code, fromWarehouseID, toWarehouseID, state, createdAt, goodsInfo];
}

class TransferGoodsItem extends Equatable {
  final int productID;
  final String? productName;
  final String? spec;
  final String? barcode;
  final int count;
  final int? actualCount;

  const TransferGoodsItem({
    required this.productID,
    this.productName,
    this.spec,
    this.barcode,
    required this.count,
    this.actualCount,
  });

  factory TransferGoodsItem.fromJson(Map<String, dynamic> json) {
    return TransferGoodsItem(
      productID: json['productID'] as int? ?? 0,
      productName: json['productName'] as String?,
      spec: json['spec'] as String?,
      barcode: json['barcode'] as String?,
      count: json['count'] as int? ?? 0,
      actualCount: json['actualCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'count': count,
    };
  }

  @override
  List<Object?> get props => [productID, productName, count];
}