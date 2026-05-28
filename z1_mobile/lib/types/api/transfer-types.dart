// ============================================================
// 调拨相关类型
// 从 z1-mid SDK transfer-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 调拨单类型
// ============================================================

enum TransferType {
  standard('standard'),
  nonStandard('nonStandard');

  final String value;
  const TransferType(this.value);

  static TransferType? fromValue(String? value) {
    if (value == null) return null;
    return TransferType.values.cast<TransferType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 调拨单状态
// ============================================================

enum TransferState {
  pending(1),      // 待审核
  draft(2),        // 草稿
  approved(5),     // 已审核
  terminated(9),   // 已终止
  pendingConfirm(10), // 待确认
  confirmed(11),   // 已确认
  shipped(12);     // 已发货

  final int value;
  const TransferState(this.value);

  static TransferState fromValue(int value) {
    return TransferState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransferState.pending,
    );
  }
}

// ============================================================
// 调拨单商品明细
// ============================================================

class TransferGoodsItem {
  final List<GoodsSerial>? goods;
  final int? quantity;
  final SkuID productId;

  TransferGoodsItem({
    this.goods,
    this.quantity,
    required this.productId,
  });

  factory TransferGoodsItem.fromJson(Map<String, dynamic> json) {
    return TransferGoodsItem(
      goods: (json['goods'] as List<dynamic>?)
          ?.map((e) => GoodsSerial.fromJson(e as Map<String, dynamic>))
          .toList(),
      quantity: json['quantity'] as int?,
      productId: json['productId'] as SkuID,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goods': goods?.map((e) => e.toJson()).toList(),
      'quantity': quantity,
      'productId': productId,
    };
  }
}

// ============================================================
// 商品序列号
// ============================================================

class GoodsSerial {
  final GoodsID id;
  final String serial;

  GoodsSerial({
    required this.id,
    required this.serial,
  });

  factory GoodsSerial.fromJson(Map<String, dynamic> json) {
    return GoodsSerial(
      id: json['id'] as GoodsID,
      serial: json['serial'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial': serial,
    };
  }
}

// ============================================================
// 调拨单
// ============================================================

class Transfer {
  final TransferID transferID;
  final UnixTimestamp createdAt;
  final UserIdent createdBy;
  final int outWarehouseID;
  final int? inWarehouseID;
  final List<TransferGoodsItem> goodsInfo;
  final TransferState status;
  final UnixTimestamp? updatedAt;
  final UserIdent? updatedBy;
  final String? remarks;
  final TransferType type;

  Transfer({
    required this.transferID,
    required this.createdAt,
    required this.createdBy,
    required this.outWarehouseID,
    this.inWarehouseID,
    required this.goodsInfo,
    required this.status,
    this.updatedAt,
    this.updatedBy,
    this.remarks,
    required this.type,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      transferID: json['transferID'] as TransferID,
      createdAt: json['createdAt'] as UnixTimestamp,
      createdBy: json['createdBy'] as UserIdent,
      outWarehouseID: json['outWarehouseID'] as int,
      inWarehouseID: json['inWarehouseID'] as int?,
      goodsInfo: (json['goodsInfo'] as List<dynamic>)
          .map((e) => TransferGoodsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: TransferState.fromValue(json['status'] as int? ?? 1),
      updatedAt: json['updatedAt'] as UnixTimestamp?,
      updatedBy: json['updatedBy'] as UserIdent?,
      remarks: json['remarks'] as String?,
      type: TransferType.fromValue(json['type'] as String?) ?? TransferType.standard,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transferID': transferID,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'outWarehouseID': outWarehouseID,
      'inWarehouseID': inWarehouseID,
      'goodsInfo': goodsInfo.map((e) => e.toJson()).toList(),
      'status': status.value,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'remarks': remarks,
      'type': type.value,
    };
  }
}
