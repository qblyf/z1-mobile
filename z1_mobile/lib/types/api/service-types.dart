// ============================================================
// 服务相关类型
// 从 z1-mid SDK service-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/api/spu-types.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';
export 'package:z1_mobile/types/api/spu-types.dart';

// ============================================================
// 上架状态
// ============================================================

enum ServeListingStatus {
  listing('listing'),
  delisting('de-listing');

  final String value;
  const ServeListingStatus(this.value);

  static ServeListingStatus? fromValue(String? value) {
    if (value == null) return null;
    return ServeListingStatus.values.cast<ServeListingStatus?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 服务是否强制绑定序列号
// ============================================================

enum ServeTypeIsGoods {
  yes(1),
  no(2);

  final int value;
  const ServeTypeIsGoods(this.value);

  static ServeTypeIsGoods? fromValue(int? value) {
    if (value == null) return null;
    return ServeTypeIsGoods.values.cast<ServeTypeIsGoods?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 服务类型
// ============================================================

class ServeType {
  final ServiceID id;
  final String number;
  final String name;
  final int? cate;
  final int? cent;
  final int? costCent;
  final int? limitCent;
  final int? incomeAccount;
  final int? costAccount;
  final int? stockVendorAccount;
  final int state;
  final String? remarks;
  final int createdAt;
  final UnixTimestamp? updatedAt;
  final List<int>? couponClassID;
  final ServeTypeIsGoods? isGoods;
  final String? detailImage;
  final String? shortName;
  final String? activityDescription;
  final int? vendorID;
  final List<SpuKeyword> privateKeywords;
  final List<String> keywords;
  final String? benefits;
  final String? description;
  final List<String> mainImages;
  final List<String> detailImages;
  final int? weight;
  final int? virtualSales;
  final bool useCoin;
  final List<DepartmentID> departments;
  final List<SkuID> recommendSkus;
  final List<SpuID> recommendSpus;
  final List<ServiceID> recommendServices;
  final List<ServiceID> bindServices;
  final ServeListingStatus listingStatus;
  final List<int>? mallThirdCate;

  ServeType({
    required this.id,
    required this.number,
    required this.name,
    this.cate,
    this.cent,
    this.costCent,
    this.limitCent,
    this.incomeAccount,
    this.costAccount,
    this.stockVendorAccount,
    required this.state,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
    this.couponClassID,
    this.isGoods,
    this.detailImage,
    this.shortName,
    this.activityDescription,
    this.vendorID,
    required this.privateKeywords,
    required this.keywords,
    this.benefits,
    this.description,
    required this.mainImages,
    required this.detailImages,
    this.weight,
    this.virtualSales,
    required this.useCoin,
    required this.departments,
    required this.recommendSkus,
    required this.recommendSpus,
    required this.recommendServices,
    required this.bindServices,
    required this.listingStatus,
    this.mallThirdCate,
  });

  factory ServeType.fromJson(Map<String, dynamic> json) {
    return ServeType(
      id: json['id'] as ServiceID,
      number: json['number'] as String,
      name: json['name'] as String,
      cate: json['cate'] as int?,
      cent: json['cent'] as int?,
      costCent: json['costCent'] as int?,
      limitCent: json['limitCent'] as int?,
      incomeAccount: json['incomeAccount'] as int?,
      costAccount: json['costAccount'] as int?,
      stockVendorAccount: json['stockVendorAccount'] as int?,
      state: json['state'] as int? ?? 1,
      remarks: json['remarks'] as String?,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as UnixTimestamp?,
      couponClassID: (json['couponClassID'] as List<dynamic>?)?.cast<int>(),
      isGoods: ServeTypeIsGoods.fromValue(json['isGoods'] as int?),
      detailImage: json['detailImage'] as String?,
      shortName: json['shortName'] as String?,
      activityDescription: json['activityDescription'] as String?,
      vendorID: json['vendorID'] as int?,
      privateKeywords: (json['privateKeywords'] as List<dynamic>?)
              ?.map((e) => SpuKeyword.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      benefits: json['benefits'] as String?,
      description: json['description'] as String?,
      mainImages: (json['mainImages'] as List<dynamic>?)?.cast<String>() ?? [],
      detailImages: (json['detailImages'] as List<dynamic>?)?.cast<String>() ?? [],
      weight: json['weight'] as int?,
      virtualSales: json['virtualSales'] as int?,
      useCoin: json['useCoin'] as bool? ?? false,
      departments: (json['departments'] as List<dynamic>?)?.cast<DepartmentID>() ?? [],
      recommendSkus: (json['recommendSkus'] as List<dynamic>?)?.cast<SkuID>() ?? [],
      recommendSpus: (json['recommendSpus'] as List<dynamic>?)?.cast<SpuID>() ?? [],
      recommendServices: (json['recommendServices'] as List<dynamic>?)?.cast<ServiceID>() ?? [],
      bindServices: (json['bindServices'] as List<dynamic>?)?.cast<ServiceID>() ?? [],
      listingStatus: ServeListingStatus.fromValue(json['listingStatus'] as String?) ?? ServeListingStatus.listing,
      mallThirdCate: (json['mallThirdCate'] as List<dynamic>?)?.cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'cate': cate,
      'cent': cent,
      'costCent': costCent,
      'limitCent': limitCent,
      'incomeAccount': incomeAccount,
      'costAccount': costAccount,
      'stockVendorAccount': stockVendorAccount,
      'state': state,
      'remarks': remarks,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'couponClassID': couponClassID,
      'isGoods': isGoods?.value,
      'detailImage': detailImage,
      'shortName': shortName,
      'activityDescription': activityDescription,
      'vendorID': vendorID,
      'privateKeywords': privateKeywords.map((e) => e.toJson()).toList(),
      'keywords': keywords,
      'benefits': benefits,
      'description': description,
      'mainImages': mainImages,
      'detailImages': detailImages,
      'weight': weight,
      'virtualSales': virtualSales,
      'useCoin': useCoin,
      'departments': departments,
      'recommendSkus': recommendSkus,
      'recommendSpus': recommendSpus,
      'recommendServices': recommendServices,
      'bindServices': bindServices,
      'listingStatus': listingStatus.value,
      'mallThirdCate': mallThirdCate,
    };
  }
}
