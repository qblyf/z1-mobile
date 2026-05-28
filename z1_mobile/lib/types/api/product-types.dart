// ============================================================
// Product Types - Auto-generated from z1-mid SDK types
// DO NOT EDIT MANUALLY
// Generated at: 2026-05-27
// Source: /Users/fan/www/AI/z1/z1-mid/src/types/product-fn-types.ts
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 商品选择相关类型
// ============================================================

/// 获取选择商品数据返回类型
class GetSelectProductDataResult {
  /// 商品列表
  final List<GetSelectProductDataProduct> products;
  /// 商品分类列表
  final List<GetSelectProductDataCategory> categories;

  GetSelectProductDataResult({
    required this.products,
    required this.categories,
  });

  factory GetSelectProductDataResult.fromJson(Map<String, dynamic> json) {
    return GetSelectProductDataResult(
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => GetSelectProductDataProduct.fromJson(e))
          .toList() ?? [],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => GetSelectProductDataCategory.fromJson(e))
          .toList() ?? [],
    );
  }
}

/// 商品数据
class GetSelectProductDataProduct {
  final SkuID id;
  final String name;
  final List<String>? gtins;
  final String? privateBarcode;
  final CateID cateID;
  final List<CateID> cateIDChain;

  GetSelectProductDataProduct({
    required this.id,
    required this.name,
    this.gtins,
    this.privateBarcode,
    required this.cateID,
    required this.cateIDChain,
  });

  factory GetSelectProductDataProduct.fromJson(Map<String, dynamic> json) {
    return GetSelectProductDataProduct(
      id: json['id'] as SkuID,
      name: json['name'] as String,
      gtins: (json['gtins'] as List<dynamic>?)?.cast<String>(),
      privateBarcode: json['privateBarcode'] as String?,
      cateID: json['cateID'] as CateID,
      cateIDChain: (json['cateIDChain'] as List<dynamic>?)
          ?.map((e) => e as CateID)
          .toList() ?? [],
    );
  }
}

/// 分类数据
class GetSelectProductDataCategory {
  final CateID id;
  final String name;
  final String? spell;
  final CateID? pid;
  final int? order;

  GetSelectProductDataCategory({
    required this.id,
    required this.name,
    this.spell,
    this.pid,
    this.order,
  });

  factory GetSelectProductDataCategory.fromJson(Map<String, dynamic> json) {
    return GetSelectProductDataCategory(
      id: json['id'] as CateID,
      name: json['name'] as String,
      spell: json['spell'] as String?,
      pid: json['pid'] as CateID?,
      order: json['order'] as int?,
    );
  }
}

// ============================================================
// SKU 选择基础数据（商品选购核心类型）
// ============================================================

/// 获取 SKU 选择基础数据（全部 SKU，用于商品选购页面）
class GetSelectSKUBaseDataItem {
  final SkuID skuID;
  final String skuName;
  final List<String>? gtins;
  final String? privateBarcode;
  final ProductHasSerial hasSerial;
  final String spuName;
  final SpuID spuID;
  final List<CateID> spuCateChain;
  final CateID spuCateID;
  final int weight;
  final String? spell;
  final String? brand;
  final String? series;
  final String? generation;
  final ProductState state;
  final SalesState salesState;
  
  /// 商城三级分类 ID 数组（第三级 = 数组最后一个元素）
  /// ⚠️ 注意：这是商城分类ID，不要用 spuCateID 匹配
  final List<int> mallThirdCate;
  
  final String? modelCode;

  GetSelectSKUBaseDataItem({
    required this.skuID,
    required this.skuName,
    this.gtins,
    this.privateBarcode,
    required this.hasSerial,
    required this.spuName,
    required this.spuID,
    required this.spuCateChain,
    required this.spuCateID,
    required this.weight,
    this.spell,
    this.brand,
    this.series,
    this.generation,
    required this.state,
    required this.salesState,
    required this.mallThirdCate,
    this.modelCode,
  });

  factory GetSelectSKUBaseDataItem.fromJson(Map<String, dynamic> json) {
    return GetSelectSKUBaseDataItem(
      skuID: json['skuID'] as SkuID,
      skuName: json['skuName'] as String,
      gtins: (json['gtins'] as List<dynamic>?)?.cast<String>(),
      privateBarcode: json['privateBarcode'] as String?,
      hasSerial: ProductHasSerial.fromValue(json['hasSerial'] as int? ?? 0),
      spuName: json['spuName'] as String,
      spuID: json['spuID'] as SpuID,
      spuCateChain: (json['spuCateChain'] as List<dynamic>?)
          ?.map((e) => e as CateID)
          .toList() ?? [],
      spuCateID: json['spuCateID'] as CateID,
      weight: json['weight'] as int? ?? 0,
      spell: json['spell'] as String?,
      brand: json['brand'] as String?,
      series: json['series'] as String?,
      generation: json['generation'] as String?,
      state: ProductState.fromValue(json['state'] as int? ?? 0),
      salesState: SalesState.fromValue(json['salesState'] as int? ?? 0),
      mallThirdCate: (json['mallThirdCate'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
      modelCode: json['modelCode'] as String?,
    );
  }

  /// 获取商城三级分类ID（取数组最后一个元素）
  int? get mallThirdCateId => mallThirdCate.isNotEmpty ? mallThirdCate.last : null;
}

// ============================================================
// 商品列表查询参数
// ============================================================

class GetProductListByConditionParams {
  final List<SkuID>? skuIDs;
  final List<SpuID>? spuIDs;
  final List<CateID>? cates;
  final List<String>? stockStates;
  final List<String>? states;
  final List<String>? recommends;
  final int? hasSerial;
  final int? minCreatAt;
  final int? maxCreatAt;
  final int? offset;
  final int? limit;

  GetProductListByConditionParams({
    this.skuIDs,
    this.spuIDs,
    this.cates,
    this.stockStates,
    this.states,
    this.recommends,
    this.hasSerial,
    this.minCreatAt,
    this.maxCreatAt,
    this.offset,
    this.limit,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (skuIDs != null) 'skuIDs': skuIDs!.join(','),
      if (spuIDs != null) 'spuIDs': spuIDs!.join(','),
      if (cates != null) 'cates': cates!.join(','),
      if (stockStates != null) 'stockStates': stockStates!.join(','),
      if (states != null) 'states': states!.join(','),
      if (recommends != null) 'recommends': recommends!.join(','),
      if (hasSerial != null) 'hasSerial': hasSerial,
      if (minCreatAt != null) 'minCreatAt': minCreatAt,
      if (maxCreatAt != null) 'maxCreatAt': maxCreatAt,
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
    };
  }
}

// ============================================================
// 商品操作参数
// ============================================================

class AddProductParams {
  final String name;
  final CateID cateID;
  final int? price;
  final int? marketPrice;
  final int? costPrice;
  final int? limitPrice;
  final int? weight;
  final String? unit;
  final String? remark;
  final ProductHasSerial hasSerial;
  final String? thumbnail;
  final String? barcode;

  AddProductParams({
    required this.name,
    required this.cateID,
    this.price,
    this.marketPrice,
    this.costPrice,
    this.limitPrice,
    this.weight,
    this.unit,
    this.remark,
    this.hasSerial = ProductHasSerial.no,
    this.thumbnail,
    this.barcode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cateID': cateID,
      if (price != null) 'price': price,
      if (marketPrice != null) 'marketPrice': marketPrice,
      if (costPrice != null) 'costPrice': costPrice,
      if (limitPrice != null) 'limitPrice': limitPrice,
      if (weight != null) 'weight': weight,
      if (unit != null) 'unit': unit,
      if (remark != null) 'remark': remark,
      'hasSerial': hasSerial.value,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (barcode != null) 'barcode': barcode,
    };
  }
}

class BatchEditProductParams {
  final List<SkuID> ids;
  final String? name;
  final int? price;
  final int? marketPrice;
  final int? costPrice;
  final int? limitPrice;
  final int? weight;
  final String? unit;
  final String? remark;
  final String? thumbnail;

  BatchEditProductParams({
    required this.ids,
    this.name,
    this.price,
    this.marketPrice,
    this.costPrice,
    this.limitPrice,
    this.weight,
    this.unit,
    this.remark,
    this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      'ids': ids,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (marketPrice != null) 'marketPrice': marketPrice,
      if (costPrice != null) 'costPrice': costPrice,
      if (limitPrice != null) 'limitPrice': limitPrice,
      if (weight != null) 'weight': weight,
      if (unit != null) 'unit': unit,
      if (remark != null) 'remark': remark,
      if (thumbnail != null) 'thumbnail': thumbnail,
    };
  }
}
