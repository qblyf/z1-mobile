// ============================================================
// 序列号相关类型
// 基于 serial-query-detail-prd.md 文档
// ============================================================

// Types used: int, String from Dart core

// ============================================================
// 商品状态枚举
// ============================================================

enum GoodsStatus {
  inStock('in_stock'),     // 在库
  sold('sold'),           // 已售
  transferred('transferred'); // 已调拨

  final String value;
  const GoodsStatus(this.value);

  static GoodsStatus? fromValue(String? value) {
    if (value == null) return null;
    return GoodsStatus.values.cast<GoodsStatus?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 进出库记录类型
// ============================================================

enum TraceType {
  inbound('inbound'),         // 入库
  outbound('outbound'),        // 出库
  transferIn('transfer_in'),   // 调拨入库
  transferOut('transfer_out'); // 调拨出库

  final String value;
  const TraceType(this.value);

  static TraceType? fromValue(String? value) {
    if (value == null) return null;
    return TraceType.values.cast<TraceType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 仓库信息
// ============================================================

class WarehouseInfo {
  final int id;
  final String name;

  WarehouseInfo({
    required this.id,
    required this.name,
  });

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    return WarehouseInfo(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// ============================================================
// 商品信息（序列号查询返回）
// ============================================================

class SerialGoodsInfo {
  final int id;
  final String name;
  final String sku;
  final String barcode;
  final String? weight;
  final String? category;

  SerialGoodsInfo({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    this.weight,
    this.category,
  });

  factory SerialGoodsInfo.fromJson(Map<String, dynamic> json) {
    return SerialGoodsInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String,
      weight: json['weight'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'weight': weight,
      'category': category,
    };
  }
}

// ============================================================
// 进出库记录
// ============================================================

class TraceRecord {
  final int id;
  final int time;
  final TraceType type;
  final String? sourceNo;
  final String? targetNo;
  final int warehouseId;
  final String warehouseName;
  final int operatorId;
  final String operatorName;
  final String? remark;

  TraceRecord({
    required this.id,
    required this.time,
    required this.type,
    this.sourceNo,
    this.targetNo,
    required this.warehouseId,
    required this.warehouseName,
    required this.operatorId,
    required this.operatorName,
    this.remark,
  });

  factory TraceRecord.fromJson(Map<String, dynamic> json) {
    return TraceRecord(
      id: json['id'] as int,
      time: json['time'] as int,
      type: TraceType.fromValue(json['type'] as String?) ?? TraceType.inbound,
      sourceNo: json['sourceNo'] as String?,
      targetNo: json['targetNo'] as String?,
      warehouseId: json['warehouseId'] as int,
      warehouseName: json['warehouseName'] as String,
      operatorId: json['operatorId'] as int,
      operatorName: json['operatorName'] as String,
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'type': type.value,
      'sourceNo': sourceNo,
      'targetNo': targetNo,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'remark': remark,
    };
  }
}

// ============================================================
// 序列号查询结果
// ============================================================

class SerialSearchResult {
  final SerialGoodsInfo goods;
  final WarehouseInfo? currentWarehouse;
  final int currentQuantity;
  final GoodsStatus status;
  final List<TraceRecord>? traceList;

  SerialSearchResult({
    required this.goods,
    this.currentWarehouse,
    required this.currentQuantity,
    required this.status,
    this.traceList,
  });

  factory SerialSearchResult.fromJson(Map<String, dynamic> json) {
    return SerialSearchResult(
      goods: SerialGoodsInfo.fromJson(json['goods'] as Map<String, dynamic>),
      currentWarehouse: json['currentWarehouse'] != null
          ? WarehouseInfo.fromJson(json['currentWarehouse'] as Map<String, dynamic>)
          : null,
      currentQuantity: json['currentQuantity'] as int? ?? 0,
      status: GoodsStatus.fromValue(json['status'] as String?) ?? GoodsStatus.inStock,
      traceList: (json['traceList'] as List<dynamic>?)
          ?.map((e) => TraceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goods': goods.toJson(),
      'currentWarehouse': currentWarehouse?.toJson(),
      'currentQuantity': currentQuantity,
      'status': status.value,
      'traceList': traceList?.map((e) => e.toJson()).toList(),
    };
  }
}
