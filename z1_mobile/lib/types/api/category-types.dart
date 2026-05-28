// ============================================================
// 分类相关类型
// 从 z1-mid SDK category-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 分类类型
// ============================================================

enum CategoryType {
  goods(1),         // 商品
  department(2),     // 部门
  warehouse(3),      // 仓库
  contact(4),       // 往来单位
  label(5),         // 标签
  paymentMethod(6), // 支付方式
  service(7),       // 服务
  goodsPrice(8),     // 商品价格
  spuCategory(9),   // SPU分类
  consumable(10),    // 低值易耗品分类
  boothCategory(11), // 展位分类
  displayCategory(12), // 展台分类
  taskCategory(13),  // 任务分类
  contractCategory(14), // 合同分类
  inspectionCategory(15), // 巡店分类
  selfCheckCategory(16), // 自检分类
  policyCategory(17);  // 政策分类

  final int value;
  const CategoryType(this.value);

  static CategoryType fromValue(int value) {
    return CategoryType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CategoryType.goods,
    );
  }
}

// ============================================================
// 分类状态
// ============================================================

enum CategoryState {
  normal(1),
  disabled(2);

  final int value;
  const CategoryState(this.value);

  static CategoryState fromValue(int value) {
    return CategoryState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CategoryState.normal,
    );
  }
}

// ============================================================
// 分类
// ============================================================

class Category {
  final CateID id;
  final String name;
  final String spell;
  final CateID pid;
  final int order;
  final CategoryType type;
  final String? remark;
  final CategoryState state;
  final List<CateID> chain;
  final String? icon;
  final String? privateIcon;
  final int createdAt;
  final int updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.spell,
    required this.pid,
    required this.order,
    required this.type,
    this.remark,
    required this.state,
    required this.chain,
    this.icon,
    this.privateIcon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as CateID,
      name: json['name'] as String,
      spell: json['spell'] as String,
      pid: json['pid'] as CateID,
      order: json['order'] as int? ?? 0,
      type: CategoryType.fromValue(json['type'] as int? ?? 1),
      remark: json['remark'] as String?,
      state: CategoryState.fromValue(json['state'] as int? ?? 1),
      chain: (json['chain'] as List<dynamic>?)?.cast<CateID>() ?? [],
      icon: json['icon'] as String?,
      privateIcon: json['privateIcon'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'spell': spell,
      'pid': pid,
      'order': order,
      'type': type.value,
      'remark': remark,
      'state': state.value,
      'chain': chain,
      'icon': icon,
      'privateIcon': privateIcon,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
