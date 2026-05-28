// ============================================================
// SPU 相关类型
// 从 z1-mid SDK spu-types.ts 翻译而来
// ============================================================

// re-export common types (SpuID, ServiceID 等)
export 'package:z1_mobile/types/common.dart';

// ============================================================
// SPU 图片
// ============================================================

/// SPU 图片
class SPUImages {
  /// 缩略图
  final String? thumbnail;
  /// 主图
  final List<String>? mainImages;
  /// 详情图
  final List<String>? detailsImages;

  SPUImages({
    this.thumbnail,
    this.mainImages,
    this.detailsImages,
  });

  factory SPUImages.fromJson(Map<String, dynamic> json) {
    return SPUImages(
      thumbnail: json['thumbnail'] as String?,
      mainImages: (json['mainImages'] as List<dynamic>?)?.cast<String>(),
      detailsImages: (json['detailsImages'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'mainImages': mainImages,
      'detailsImages': detailsImages,
    };
  }
}

// ============================================================
// SPU 关键词
// ============================================================

/// SPU 关键词
class SpuKeyword {
  /// 关键词ID
  final String id;
  /// 关键词列表
  final List<String> keywords;
  /// 权重
  final int weight;

  SpuKeyword({
    required this.id,
    required this.keywords,
    required this.weight,
  });

  factory SpuKeyword.fromJson(Map<String, dynamic> json) {
    return SpuKeyword(
      id: json['id'] as String,
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      weight: json['weight'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keywords': keywords,
      'weight': weight,
    };
  }
}

// ============================================================
// 退货规则
// ============================================================

/// 退货规则
enum ReturnRules {
  no7('no7'),
  yes7('yes7'),
  yes7NoBroken('yes7-no-broken'),
  yes7NoActivated('yes7-no-activated'),
  yes7NoInstalled('yes7-no-installed'),
  yes7NoUsed('yes7-no-used'),
  yes7NoCustomized('yes7-no-customized'),
  yes7NoSealingStripsBroken('yes7-no-sealing-strips-borken'),
  yes15('yes15'),
  yes30('yes30');

  final String value;
  const ReturnRules(this.value);

  static ReturnRules? fromValue(String? value) {
    if (value == null) return null;
    return ReturnRules.values.cast<ReturnRules?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 是否可用积分
// ============================================================

/// 是否可用积分
enum IsCoin {
  yes('yes'),
  no('no');

  final String value;
  const IsCoin(this.value);

  static IsCoin? fromValue(String? value) {
    if (value == null) return null;
    return IsCoin.values.cast<IsCoin?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 回收状态
// ============================================================

/// 回收状态
enum RecycleState {
  recyclable('recyclable'),
  unrecyclable('unrecyclable');

  final String value;
  const RecycleState(this.value);

  static RecycleState? fromValue(String? value) {
    if (value == null) return null;
    return RecycleState.values.cast<RecycleState?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}
