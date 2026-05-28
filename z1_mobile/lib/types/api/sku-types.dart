// ============================================================
// SKU 相关类型
// 从 z1-mid SDK sku-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// SKU 状态（与 common.dart 中的 ProductState 不同！）
// SDK 值：1=上架, 2=下架, 3=缺货
// ============================================================

enum SkuState {
  onShelf(1),
  offShelf(2),
  outOfStock(3);

  final int value;
  const SkuState(this.value);

  static SkuState fromValue(int value) {
    return SkuState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SkuState.offShelf,
    );
  }
}

// ============================================================
// 商品推荐类型
// ============================================================

enum ProductRecommend {
  notRecommended(0),
  recommended(1);

  final int value;
  const ProductRecommend(this.value);

  static ProductRecommend fromValue(int value) {
    return ProductRecommend.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductRecommend.notRecommended,
    );
  }
}

// ============================================================
// 商品库存状态
// ============================================================

enum ProductStockState {
  sufficient(1),
  warning(2),
  outOfStock(3);

  final int value;
  const ProductStockState(this.value);

  static ProductStockState fromValue(int value) {
    return ProductStockState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductStockState.sufficient,
    );
  }
}

// ============================================================
// 商品序列号规则
// 'auto' 表示位数可变，数字表示固定位数
// ============================================================

class ProductSerialRules {
  final dynamic serial;  // 'auto' | number
  final dynamic meid;   // 'auto' | number
  final dynamic sn2;    // 'auto' | number

  ProductSerialRules({
    required this.serial,
    required this.meid,
    required this.sn2,
  });

  factory ProductSerialRules.fromJson(Map<String, dynamic> json) {
    return ProductSerialRules(
      serial: json['serial'],
      meid: json['meid'],
      sn2: json['sn2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial': serial,
      'meid': meid,
      'sn2': sn2,
    };
  }
}

// ============================================================
// SKU 类型
// ============================================================

class SKU {
  final SkuID id;
  final int spuID;
  final String name;
  final String? detail;
  final SkuState state;
  final UnixTimestamp? onShelveTime;
  final UnixTimestamp? offShelveTime;
  final ProductRecommend recommend;
  final UnixTimestamp productAddTime;
  final UnixTimestamp? modifyTime;
  final String? shortName;
  final int? price;
  final int? marketPrice;
  final int? costPrice;
  final int? limitPrice;
  final String? remarks;
  final ProductHasSerial hasSerial;
  final ProductSerialRules? serialRules;
  final List<int>? services;
  final String? thumbnail;
  final List<String>? gtins;
  final String? privateBarcode;
  final String? privateThumbnail;
  final int? grossWeight;
  final RMBFen? officialWebPrice;
  final int? virtualStock;
  final String? unit;
  final bool? isAllowance;
  final RMBFen? activityCent;
  final List<ServiceID> bindServices;

  SKU({
    required this.id,
    required this.spuID,
    required this.name,
    this.detail,
    required this.state,
    this.onShelveTime,
    this.offShelveTime,
    required this.recommend,
    required this.productAddTime,
    this.modifyTime,
    this.shortName,
    this.price,
    this.marketPrice,
    this.costPrice,
    this.limitPrice,
    this.remarks,
    required this.hasSerial,
    this.serialRules,
    this.services,
    this.thumbnail,
    this.gtins,
    this.privateBarcode,
    this.privateThumbnail,
    this.grossWeight,
    this.officialWebPrice,
    this.virtualStock,
    this.unit,
    this.isAllowance,
    this.activityCent,
    required this.bindServices,
  });

  factory SKU.fromJson(Map<String, dynamic> json) {
    return SKU(
      id: json['id'] as SkuID,
      spuID: json['spuID'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String?,
      state: SkuState.fromValue(json['state'] as int? ?? 2),
      onShelveTime: json['onShelveTime'] as UnixTimestamp?,
      offShelveTime: json['offShelveTime'] as UnixTimestamp?,
      recommend: ProductRecommend.fromValue(json['recommend'] as int? ?? 0),
      productAddTime: json['productAddTime'] as UnixTimestamp,
      modifyTime: json['modifyTime'] as UnixTimestamp?,
      shortName: json['shortName'] as String?,
      price: json['price'] as int?,
      marketPrice: json['marketPrice'] as int?,
      costPrice: json['costPrice'] as int?,
      limitPrice: json['limitPrice'] as int?,
      remarks: json['remarks'] as String?,
      hasSerial: ProductHasSerial.fromValue(json['hasSerial'] as int? ?? 0),
      serialRules: json['serialRules'] != null
          ? ProductSerialRules.fromJson(json['serialRules'] as Map<String, dynamic>)
          : null,
      services: (json['services'] as List<dynamic>?)?.cast<int>(),
      thumbnail: json['thumbnail'] as String?,
      gtins: (json['gtins'] as List<dynamic>?)?.cast<String>(),
      privateBarcode: json['privateBarcode'] as String?,
      privateThumbnail: json['privateThumbnail'] as String?,
      grossWeight: json['grossWeight'] as int?,
      officialWebPrice: json['officialWebPrice'] as RMBFen?,
      virtualStock: json['virtualStock'] as int?,
      unit: json['unit'] as String?,
      isAllowance: json['isAllowance'] as bool?,
      activityCent: json['activityCent'] as RMBFen?,
      bindServices: (json['bindServices'] as List<dynamic>?)
              ?.map((e) => e as ServiceID)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spuID': spuID,
      'name': name,
      'detail': detail,
      'state': state.value,
      'onShelveTime': onShelveTime,
      'offShelveTime': offShelveTime,
      'recommend': recommend.value,
      'productAddTime': productAddTime,
      'modifyTime': modifyTime,
      'shortName': shortName,
      'price': price,
      'marketPrice': marketPrice,
      'costPrice': costPrice,
      'limitPrice': limitPrice,
      'remarks': remarks,
      'hasSerial': hasSerial.value,
      'serialRules': serialRules?.toJson(),
      'services': services,
      'thumbnail': thumbnail,
      'gtins': gtins,
      'privateBarcode': privateBarcode,
      'privateThumbnail': privateThumbnail,
      'grossWeight': grossWeight,
      'officialWebPrice': officialWebPrice,
      'virtualStock': virtualStock,
      'unit': unit,
      'isAllowance': isAllowance,
      'activityCent': activityCent,
      'bindServices': bindServices,
    };
  }
}
