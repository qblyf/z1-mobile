// ============================================================
// 库存相关类型
// 从 z1-mid SDK stock-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 商品库存统计
// ============================================================

class ProductStockItem {
  final SkuID productID;
  final int stock;

  ProductStockItem({
    required this.productID,
    required this.stock,
  });

  factory ProductStockItem.fromJson(Map<String, dynamic> json) {
    return ProductStockItem(
      productID: json['productID'] as SkuID,
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'stock': stock,
    };
  }
}

// ============================================================
// 分类库存统计
// ============================================================

class CateStockItem {
  final int cateId;
  final int stock;

  CateStockItem({
    required this.cateId,
    required this.stock,
  });

  factory CateStockItem.fromJson(Map<String, dynamic> json) {
    return CateStockItem(
      cateId: json['cateId'] as int,
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cateId': cateId,
      'stock': stock,
    };
  }
}

// ============================================================
// SKU 库存调拨信息
// ============================================================

class SkuStockTransferInfo {
  final SkuID skuID;
  final int stock;
  final int inbound;
  final int outbound;

  SkuStockTransferInfo({
    required this.skuID,
    required this.stock,
    required this.inbound,
    required this.outbound,
  });

  factory SkuStockTransferInfo.fromJson(Map<String, dynamic> json) {
    return SkuStockTransferInfo(
      skuID: json['skuID'] as SkuID,
      stock: json['stock'] as int? ?? 0,
      inbound: json['inbound'] as int? ?? 0,
      outbound: json['outbound'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuID': skuID,
      'stock': stock,
      'inbound': inbound,
      'outbound': outbound,
    };
  }
}

// ============================================================
// 库存价格统计
// ============================================================

class StockPriceItem {
  final SkuID skuID;
  final String skuName;
  final int warehouseID;
  final String warehouseName;
  final int stock;
  final RMBFen? costPrice;
  final RMBFen? limitPrice;
  final RMBFen? listPrice;

  StockPriceItem({
    required this.skuID,
    required this.skuName,
    required this.warehouseID,
    required this.warehouseName,
    required this.stock,
    this.costPrice,
    this.limitPrice,
    this.listPrice,
  });

  factory StockPriceItem.fromJson(Map<String, dynamic> json) {
    return StockPriceItem(
      skuID: json['skuID'] as SkuID,
      skuName: json['skuName'] as String,
      warehouseID: json['warehouseID'] as int,
      warehouseName: json['warehouseName'] as String,
      stock: json['stock'] as int? ?? 0,
      costPrice: json['costPrice'] as RMBFen?,
      limitPrice: json['limitPrice'] as RMBFen?,
      listPrice: json['listPrice'] as RMBFen?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuID': skuID,
      'skuName': skuName,
      'warehouseID': warehouseID,
      'warehouseName': warehouseName,
      'stock': stock,
      'costPrice': costPrice,
      'limitPrice': limitPrice,
      'listPrice': listPrice,
    };
  }
}

// ============================================================
// 仓库库存统计
// ============================================================

class WarehouseStockItem {
  final SkuID skuID;
  final int warehouseID;
  final int departmentID;
  final int stock;
  final int lockStock;
  final int saleStock;
  final int virtualStock;

  WarehouseStockItem({
    required this.skuID,
    required this.warehouseID,
    required this.departmentID,
    required this.stock,
    required this.lockStock,
    required this.saleStock,
    required this.virtualStock,
  });

  factory WarehouseStockItem.fromJson(Map<String, dynamic> json) {
    return WarehouseStockItem(
      skuID: json['skuID'] as SkuID,
      warehouseID: json['warehouseID'] as int,
      departmentID: json['departmentID'] as int,
      stock: json['stock'] as int? ?? 0,
      lockStock: json['lockStock'] as int? ?? 0,
      saleStock: json['saleStock'] as int? ?? 0,
      virtualStock: json['virtualStock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuID': skuID,
      'warehouseID': warehouseID,
      'departmentID': departmentID,
      'stock': stock,
      'lockStock': lockStock,
      'saleStock': saleStock,
      'virtualStock': virtualStock,
    };
  }
}
