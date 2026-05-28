// ============================================================
// 采购相关类型
// 从 z1-mid SDK purchase-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 采购单据状态
// ============================================================

enum PurchaseState {
  normal(1),
  draft(2),
  pending(3);  // 待审核

  final int value;
  const PurchaseState(this.value);

  static PurchaseState fromValue(int value) {
    return PurchaseState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PurchaseState.normal,
    );
  }
}

// ============================================================
// 是否成本调价
// ============================================================

enum IsChangeCostPrice {
  no(0),
  yes(1);

  final int value;
  const IsChangeCostPrice(this.value);

  static IsChangeCostPrice fromValue(int value) {
    return IsChangeCostPrice.values.firstWhere(
      (e) => e.value == value,
      orElse: () => IsChangeCostPrice.no,
    );
  }
}

// ============================================================
// 采购单类型
// ============================================================

enum PurchaseType {
  goods(1),         // 正常采购单
  goodsRecycle(2);  // 二手采购单

  final int value;
  const PurchaseType(this.value);

  static PurchaseType fromValue(int value) {
    return PurchaseType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PurchaseType.goods,
    );
  }
}

// ============================================================
// 采购标准商品
// ============================================================

class PurchaseProducts {
  final SkuID product;
  final RMBFen cent;
  final RMBFen? costPrice;
  final List<GoodsFullSerial>? serial;
  final int? count;
  final RMBFen? rebatePrice;
  final List<int>? rebatePolicyIDs;

  PurchaseProducts({
    required this.product,
    required this.cent,
    this.costPrice,
    this.serial,
    this.count,
    this.rebatePrice,
    this.rebatePolicyIDs,
  });

  factory PurchaseProducts.fromJson(Map<String, dynamic> json) {
    return PurchaseProducts(
      product: json['product'] as SkuID,
      cent: json['cent'] as RMBFen,
      costPrice: json['costPrice'] as RMBFen?,
      serial: (json['serial'] as List<dynamic>?)
          ?.map((e) => GoodsFullSerial.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
      rebatePrice: json['rebatePrice'] as RMBFen?,
      rebatePolicyIDs: (json['rebatePolicyIDs'] as List<dynamic>?)?.cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'cent': cent,
      'costPrice': costPrice,
      'serial': serial?.map((e) => e.toJson()).toList(),
      'count': count,
      'rebatePrice': rebatePrice,
      'rebatePolicyIDs': rebatePolicyIDs,
    };
  }
}

// ============================================================
// 商品完整序列号信息
// ============================================================

class GoodsFullSerial {
  final GoodsID id;
  final String serial;

  GoodsFullSerial({
    required this.id,
    required this.serial,
  });

  factory GoodsFullSerial.fromJson(Map<String, dynamic> json) {
    return GoodsFullSerial(
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
// 采购非标准商品
// ============================================================

class PurchaseItem {
  final SkuID productID;
  final GoodsFullSerial serial;
  final RMBFen costPrice;
  final int condition;  // NonStandardCondition

  PurchaseItem({
    required this.productID,
    required this.serial,
    required this.costPrice,
    required this.condition,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      productID: json['productID'] as SkuID,
      serial: GoodsFullSerial.fromJson(json['serial'] as Map<String, dynamic>),
      costPrice: json['costPrice'] as RMBFen,
      condition: json['condition'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'serial': serial.toJson(),
      'costPrice': costPrice,
      'condition': condition,
    };
  }
}

// ============================================================
// 采购货品标签
// ============================================================

class PurchaseLabels {
  final String serial;
  final List<int> labelIDs;  // LabelID[]

  PurchaseLabels({
    required this.serial,
    required this.labelIDs,
  });

  factory PurchaseLabels.fromJson(Map<String, dynamic> json) {
    return PurchaseLabels(
      serial: json['serial'] as String,
      labelIDs: (json['labelIDs'] as List<dynamic>).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial': serial,
      'labelIDs': labelIDs,
    };
  }
}

// ============================================================
// 采购单据
// ============================================================

class Purchase {
  final int purchaseID;
  final int vendorID;
  final dynamic products;  // PurchaseProducts[] | PurchaseItem[] | null
  final UserIdent creatorIdent;
  final PurchaseState state;
  final String? remarks;
  final UnixTimestamp createdAt;
  final UnixTimestamp? updatedAt;
  final int? warehouseID;
  final UserIdent? updateByIdent;
  final UnixTimestamp? expectedAt;
  final String? number;
  final IsChangeCostPrice? isChangeCostPrice;
  final List<UserIdent>? auditorIdents;
  final PurchaseType? type;
  final List<PurchaseLabels>? labels;
  final String? purchaseOrderID;
  final String? purchaseOrderNumber;

  Purchase({
    required this.purchaseID,
    required this.vendorID,
    this.products,
    required this.creatorIdent,
    required this.state,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
    this.warehouseID,
    this.updateByIdent,
    this.expectedAt,
    this.number,
    this.isChangeCostPrice,
    this.auditorIdents,
    this.type,
    this.labels,
    this.purchaseOrderID,
    this.purchaseOrderNumber,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      purchaseID: json['purchaseID'] as int,
      vendorID: json['vendorID'] as int,
      products: json['products'],
      creatorIdent: json['creatorIdent'] as UserIdent,
      state: PurchaseState.fromValue(json['state'] as int? ?? 1),
      remarks: json['remarks'] as String?,
      createdAt: json['createdAt'] as UnixTimestamp,
      updatedAt: json['updatedAt'] as UnixTimestamp?,
      warehouseID: json['warehouseID'] as int?,
      updateByIdent: json['updateByIdent'] as UserIdent?,
      expectedAt: json['expectedAt'] as UnixTimestamp?,
      number: json['number'] as String?,
      isChangeCostPrice: json['isChangeCostPrice'] != null
          ? IsChangeCostPrice.fromValue(json['isChangeCostPrice'] as int)
          : null,
      auditorIdents: (json['auditorIdents'] as List<dynamic>?)?.cast<UserIdent>(),
      type: json['type'] != null
          ? PurchaseType.fromValue(json['type'] as int)
          : null,
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => PurchaseLabels.fromJson(e as Map<String, dynamic>))
          .toList(),
      purchaseOrderID: json['purchaseOrderID'] as String?,
      purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseID': purchaseID,
      'vendorID': vendorID,
      'products': products,
      'creatorIdent': creatorIdent,
      'state': state.value,
      'remarks': remarks,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'warehouseID': warehouseID,
      'updateByIdent': updateByIdent,
      'expectedAt': expectedAt,
      'number': number,
      'isChangeCostPrice': isChangeCostPrice?.value,
      'auditorIdents': auditorIdents,
      'type': type?.value,
      'labels': labels?.map((e) => e.toJson()).toList(),
      'purchaseOrderID': purchaseOrderID,
      'purchaseOrderNumber': purchaseOrderNumber,
    };
  }
}
