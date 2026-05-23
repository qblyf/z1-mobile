import 'package:equatable/equatable.dart';

/// 换新补贴状态
enum RenewSubsidyStatus {
  available,
  used,
  expired,
}

/// 换新补贴券模型
/// 用于零售开单中的换新补贴选择
class RenewSubsidyModel extends Equatable {
  final int subsidyId;
  final String subsidyName;
  final int discountValue; // 补贴金额（分）
  final int minOrderAmount; // 最低订单金额（分）
  final DateTime startDate;
  final DateTime endDate;
  final RenewSubsidyStatus status;
  final int? couponClassId; // 券分类ID
  final String? couponClassName; // 券分类名称
  final String? applicableProductNames; // 适用商品名称
  final String? description; // 补贴说明

  const RenewSubsidyModel({
    required this.subsidyId,
    required this.subsidyName,
    required this.discountValue,
    required this.minOrderAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.couponClassId,
    this.couponClassName,
    this.applicableProductNames,
    this.description,
  });

  factory RenewSubsidyModel.fromJson(Map<String, dynamic> json) {
    return RenewSubsidyModel(
      subsidyId: json['subsidyId'] ?? json['subsidy_id'] ?? 0,
      subsidyName: json['subsidyName'] ?? json['subsidy_name'] ?? '',
      discountValue: json['discountValue'] ?? json['discount_value'] ?? 0,
      minOrderAmount: json['minOrderAmount'] ?? json['min_order_amount'] ?? 0,
      startDate: DateTime.tryParse(json['startDate'] ?? json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? json['end_date'] ?? '') ?? DateTime.now(),
      status: _parseStatus(json['status']),
      couponClassId: json['couponClassId'] ?? json['coupon_class_id'],
      couponClassName: json['couponClassName'] ?? json['coupon_class_name'],
      applicableProductNames: json['applicableProductNames'] ?? json['applicable_product_names'],
      description: json['description'],
    );
  }

  static RenewSubsidyStatus _parseStatus(dynamic status) {
    if (status == null) return RenewSubsidyStatus.available;
    if (status is String) {
      return switch (status.toLowerCase()) {
        'used' => RenewSubsidyStatus.used,
        'expired' => RenewSubsidyStatus.expired,
        _ => RenewSubsidyStatus.available,
      };
    }
    if (status is int) {
      return switch (status) {
        1 => RenewSubsidyStatus.available,
        2 => RenewSubsidyStatus.used,
        3 => RenewSubsidyStatus.expired,
        _ => RenewSubsidyStatus.available,
      };
    }
    return RenewSubsidyStatus.available;
  }

  bool get isAvailable => status == RenewSubsidyStatus.available;

  double get discountValueYuan => discountValue / 100;

  double get minOrderAmountYuan => minOrderAmount / 100;

  String get discountDisplay => '¥${discountValueYuan.toStringAsFixed(2)}';

  String get conditionDisplay {
    if (minOrderAmount <= 0) {
      return '无门槛';
    }
    return '满${minOrderAmountYuan.toStringAsFixed(2)}元可用';
  }

  String get validityDisplay {
    final start = '${startDate.month}/${startDate.day}';
    final end = '${endDate.month}/${endDate.day}';
    return '$start - $end';
  }

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isNotStarted => DateTime.now().isBefore(startDate);

  @override
  List<Object?> get props => [subsidyId];
}

/// 券分类模型（换新补贴分类）
class CouponClassModel extends Equatable {
  final int classId;
  final String className;
  final String? description;
  final int? count; // 该分类下可用券数量

  const CouponClassModel({
    required this.classId,
    required this.className,
    this.description,
    this.count,
  });

  factory CouponClassModel.fromJson(Map<String, dynamic> json) {
    return CouponClassModel(
      classId: json['classId'] ?? json['class_id'] ?? 0,
      className: json['className'] ?? json['class_name'] ?? '',
      description: json['description'],
      count: json['count'],
    );
  }

  @override
  List<Object?> get props => [classId];
}