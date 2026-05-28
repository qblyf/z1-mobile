// ============================================================
// 盘库相关类型
// 从 z1-mid SDK stocktaking-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 盘库状态
// ============================================================

enum StocktakingState {
  inProgress(1),  // 进行中
  completed(2);    // 已完成

  final int value;
  const StocktakingState(this.value);

  static StocktakingState fromValue(int value) {
    return StocktakingState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StocktakingState.inProgress,
    );
  }
}

// ============================================================
// 盘库计划状态
// ============================================================

enum StocktakingPlanState {
  available(1),    // 可用
  unavailable(2);  // 不可用

  final int value;
  const StocktakingPlanState(this.value);

  static StocktakingPlanState fromValue(int value) {
    return StocktakingPlanState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StocktakingPlanState.available,
    );
  }
}

// ============================================================
// 商品目标类型
// ============================================================

enum ProductTarget {
  standardOnly(1),        // 仅标准
  nonStandardOnly(2),    // 仅非标准
  both(3),              // 标准与非标准
  recycle(4);           // 掌上回收

  final int value;
  const ProductTarget(this.value);

  static ProductTarget fromValue(int value) {
    return ProductTarget.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductTarget.standardOnly,
    );
  }
}

// ============================================================
// 盘库周期
// ============================================================

class StocktakingTakeCycle {
  final String cycle;  // 'day' | 'week' | 'month'
  final List<int> day;

  StocktakingTakeCycle({
    required this.cycle,
    required this.day,
  });

  factory StocktakingTakeCycle.fromJson(Map<String, dynamic> json) {
    return StocktakingTakeCycle(
      cycle: json['cycle'] as String,
      day: (json['day'] as List<dynamic>).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cycle': cycle,
      'day': day,
    };
  }
}

// ============================================================
// 盘库库存项
// ============================================================

class StockTakingInventory {
  final String productName;
  final String serial;
  final int warehouseID;
  final String warehouseName;
  final int total;
  final List<String> gtins;
  final String? privateCode;
  final RMBFen cent;
  final RMBFen costCent;
  final int? vendorID;
  final String? nonStandardSN;
  final String? nonStandardUniqueSN;
  final String? condition;
  final String? cateName1;
  final String? cateName2;
  final String cateName;
  final String? imei;
  final String? sn2;

  StockTakingInventory({
    required this.productName,
    required this.serial,
    required this.warehouseID,
    required this.warehouseName,
    required this.total,
    required this.gtins,
    this.privateCode,
    required this.cent,
    required this.costCent,
    this.vendorID,
    this.nonStandardSN,
    this.nonStandardUniqueSN,
    this.condition,
    this.cateName1,
    this.cateName2,
    required this.cateName,
    this.imei,
    this.sn2,
  });

  factory StockTakingInventory.fromJson(Map<String, dynamic> json) {
    return StockTakingInventory(
      productName: json['productName'] as String,
      serial: json['serial'] as String,
      warehouseID: json['warehouseID'] as int,
      warehouseName: json['warehouseName'] as String,
      total: json['total'] as int? ?? 0,
      gtins: (json['gtins'] as List<dynamic>).cast<String>(),
      privateCode: json['privateCode'] as String?,
      cent: json['cent'] as RMBFen,
      costCent: json['costCent'] as RMBFen,
      vendorID: json['vendorID'] as int?,
      nonStandardSN: json['nonStandardSN'] as String?,
      nonStandardUniqueSN: json['nonStandardUniqueSN'] as String?,
      condition: json['condition'] as String?,
      cateName1: json['cateName1'] as String?,
      cateName2: json['cateName2'] as String?,
      cateName: json['cateName'] as String,
      imei: json['imei'] as String?,
      sn2: json['sn2'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'serial': serial,
      'warehouseID': warehouseID,
      'warehouseName': warehouseName,
      'total': total,
      'gtins': gtins,
      'privateCode': privateCode,
      'cent': cent,
      'costCent': costCent,
      'vendorID': vendorID,
      'nonStandardSN': nonStandardSN,
      'nonStandardUniqueSN': nonStandardUniqueSN,
      'condition': condition,
      'cateName1': cateName1,
      'cateName2': cateName2,
      'cateName': cateName,
      'imei': imei,
      'sn2': sn2,
    };
  }
}

// ============================================================
// 盘库方案
// ============================================================

class StocktakingPlan {
  final int id;
  final String title;
  final List<int> productCates;
  final StocktakingPlanState state;
  final ProductTarget productTarget;
  final String icon;
  final StocktakingTakeCycle cycle;
  final UnixTimestamp createdAt;
  final UserIdent createdBy;
  final UnixTimestamp updatedAt;
  final UserIdent updatedBy;
  final String remindText;
  final String remindTime;

  StocktakingPlan({
    required this.id,
    required this.title,
    required this.productCates,
    required this.state,
    required this.productTarget,
    required this.icon,
    required this.cycle,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.remindText,
    required this.remindTime,
  });

  factory StocktakingPlan.fromJson(Map<String, dynamic> json) {
    return StocktakingPlan(
      id: json['id'] as int,
      title: json['title'] as String,
      productCates: (json['productCates'] as List<dynamic>).cast<int>(),
      state: StocktakingPlanState.fromValue(json['state'] as int? ?? 1),
      productTarget: ProductTarget.fromValue(json['productTarget'] as int? ?? 1),
      icon: json['icon'] as String,
      cycle: StocktakingTakeCycle.fromJson(json['cycle'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as UnixTimestamp,
      createdBy: json['createdBy'] as UserIdent,
      updatedAt: json['updatedAt'] as UnixTimestamp,
      updatedBy: json['updatedBy'] as UserIdent,
      remindText: json['remindText'] as String,
      remindTime: json['remindTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'productCates': productCates,
      'state': state.value,
      'productTarget': productTarget.value,
      'icon': icon,
      'cycle': cycle.toJson(),
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'remindText': remindText,
      'remindTime': remindTime,
    };
  }
}

// ============================================================
// 盘库值班状态
// ============================================================

enum StocktakingOnDutyStatus {
  pending('pending'),      // 待确认
  inUse('in-use'),       // 在用已确认
  complete('complete'),   // 已确认
  refused('refused');     // 已拒绝

  final String value;
  const StocktakingOnDutyStatus(this.value);

  static StocktakingOnDutyStatus? fromValue(String? value) {
    if (value == null) return null;
    return StocktakingOnDutyStatus.values.cast<StocktakingOnDutyStatus?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 盘库值班记录
// ============================================================

class StocktakingOnDuty {
  final int id;
  final int warehouseID;
  final int planID;
  final UserIdent? preManager;
  final UserIdent? newManager;
  final UserIdent? createdBy;
  final UnixTimestamp createdAt;
  final UnixTimestamp? updatedAt;
  final StocktakingOnDutyStatus status;
  final String? remarks;

  StocktakingOnDuty({
    required this.id,
    required this.warehouseID,
    required this.planID,
    this.preManager,
    this.newManager,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.remarks,
  });

  factory StocktakingOnDuty.fromJson(Map<String, dynamic> json) {
    return StocktakingOnDuty(
      id: json['id'] as int,
      warehouseID: json['warehouseID'] as int,
      planID: json['planID'] as int,
      preManager: json['preManager'] as UserIdent?,
      newManager: json['newManager'] as UserIdent?,
      createdBy: json['createdBy'] as UserIdent?,
      createdAt: json['createdAt'] as UnixTimestamp,
      updatedAt: json['updatedAt'] as UnixTimestamp?,
      status: StocktakingOnDutyStatus.fromValue(json['status'] as String?) ?? StocktakingOnDutyStatus.pending,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseID': warehouseID,
      'planID': planID,
      'preManager': preManager,
      'newManager': newManager,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status.value,
      'remarks': remarks,
    };
  }
}

// ============================================================
// 盘库记录
// ============================================================

class Stocktaking {
  final int id;
  final int warehouseID;
  final int planID;
  final StocktakingState state;
  final bool isLast;
  final UnixTimestamp submittedAt;
  final UnixTimestamp createdAt;
  final UserIdent createdBy;
  final UnixTimestamp updatedAt;
  final UserIdent updatedBy;
  final String? remarks;

  Stocktaking({
    required this.id,
    required this.warehouseID,
    required this.planID,
    required this.state,
    required this.isLast,
    required this.submittedAt,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.remarks,
  });

  factory Stocktaking.fromJson(Map<String, dynamic> json) {
    return Stocktaking(
      id: json['id'] as int,
      warehouseID: json['warehouseID'] as int,
      planID: json['planID'] as int,
      state: StocktakingState.fromValue(json['state'] as int? ?? 1),
      isLast: json['isLast'] as bool? ?? false,
      submittedAt: json['submittedAt'] as UnixTimestamp,
      createdAt: json['createdAt'] as UnixTimestamp,
      createdBy: json['createdBy'] as UserIdent,
      updatedAt: json['updatedAt'] as UnixTimestamp,
      updatedBy: json['updatedBy'] as UserIdent,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseID': warehouseID,
      'planID': planID,
      'state': state.value,
      'isLast': isLast,
      'submittedAt': submittedAt,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'remarks': remarks,
    };
  }
}

// ============================================================
// 盘库仪表盘
// ============================================================

class StocktakingDashboard {
  final int warehouseID;
  final StocktakingState stocktakingState;

  StocktakingDashboard({
    required this.warehouseID,
    required this.stocktakingState,
  });

  factory StocktakingDashboard.fromJson(Map<String, dynamic> json) {
    return StocktakingDashboard(
      warehouseID: json['warehouseID'] as int,
      stocktakingState: StocktakingState.fromValue(json['stocktakingState'] as int? ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouseID': warehouseID,
      'stocktakingState': stocktakingState.value,
    };
  }
}
