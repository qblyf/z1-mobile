// ============================================================
// Mall Category Types - 商城分类类型
// Auto-generated from z1-mid SDK types
// DO NOT EDIT MANUALLY
// Generated at: 2026-05-27
// Source: /Users/fan/www/AI/z1/z1-mid/src/types/mall-category-types.ts
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 商城分类类型
// ============================================================

/// 商城分类
/// 层级结构固定3级：品类(level=1) → 品牌(level=2) → 系列(level=3)
class MallCategory {
  final MallCategoryID id;
  final String title;
  final int weight;
  final int level;
  final List<MallCategoryID> pids;
  final String? spell;
  final String? imgUrl;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;

  MallCategory({
    required this.id,
    required this.title,
    required this.weight,
    required this.level,
    required this.pids,
    this.spell,
    this.imgUrl,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory MallCategory.fromJson(Map<String, dynamic> json) {
    return MallCategory(
      id: json['id'] as MallCategoryID,
      title: json['title'] as String,
      weight: json['weight'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      pids: (json['pids'] as List<dynamic>?)
          ?.map((e) => e as MallCategoryID)
          .toList() ?? [],
      spell: json['spell'] as String?,
      imgUrl: json['imgUrl'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int? ?? 0,
      updatedBy: json['updatedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weight': weight,
      'level': level,
      'pids': pids,
      if (spell != null) 'spell': spell,
      if (imgUrl != null) 'imgUrl': imgUrl,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }

  /// 是否是顶级分类（1级分类）
  bool get isTopLevel => level == 1;

  /// 是否是2级分类（品牌）
  bool get isBrandLevel => level == 2;

  /// 是否是3级分类（系列）
  bool get isSeriesLevel => level == 3;

  /// 获取父级ID（如果有）
  MallCategoryID? get parentId => pids.isNotEmpty ? pids.last : null;

  /// 获取顶级分类ID
  MallCategoryID? get topLevelId => pids.isNotEmpty ? pids.first : (isTopLevel ? id : null);
}

/// 商城分类树节点（用于前端展示）
class MallCategoryNode {
  final MallCategory category;
  final List<MallCategoryNode> children;

  MallCategoryNode({
    required this.category,
    this.children = const [],
  });

  factory MallCategoryNode.fromJson(Map<String, dynamic> json, [List<MallCategoryNode>? children]) {
    return MallCategoryNode(
      category: MallCategory.fromJson(json),
      children: children ?? [],
    );
  }
}

/// 商城分类列表响应
class MallCategoryListResponse {
  final List<MallCategory> list;
  final int total;

  MallCategoryListResponse({
    required this.list,
    required this.total,
  });

  factory MallCategoryListResponse.fromJson(Map<String, dynamic> json) {
    return MallCategoryListResponse(
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => MallCategory.fromJson(e))
          .toList() ?? [],
      total: json['total'] as int? ?? 0,
    );
  }
}

// ============================================================
// 商城分类查询参数
// ============================================================

class GetMallCategoryListParams {
  /// 分类ID
  final MallCategoryID? id;
  /// 父级分类ID
  final MallCategoryID? pid;
  /// 层级
  final int? level;
  /// 是否包含子分类
  final bool includeChildren;

  GetMallCategoryListParams({
    this.id,
    this.pid,
    this.level,
    this.includeChildren = false,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (id != null) 'id': id,
      if (pid != null) 'pid': pid,
      if (level != null) 'level': level,
      if (includeChildren) 'includeChildren': 'true',
    };
  }
}
