import 'package:equatable/equatable.dart';

/// 代金券类型
enum CashCouponType {
  fixed, // 固定金额
  percent, // 百分比折扣
}

/// 代金券状态
enum CashCouponStatus {
  available,
  used,
  expired,
}

/// 代金券/现金券模型
/// 用于零售开单中的代金券选择
class CashCouponModel extends Equatable {
  final int couponId;
  final String couponName;
  final CashCouponType type;
  final int discountValue; // 优惠金额或折扣率（分）
  final int minOrderAmount; // 最低订单金额（分）
  final DateTime startDate;
  final DateTime endDate;
  final CashCouponStatus status;
  final List<int>? applicableProductIds; // 适用商品ID列表，null表示全部适用
  final String? applicableProductNames; // 适用商品名称

  const CashCouponModel({
    required this.couponId,
    required this.couponName,
    required this.type,
    required this.discountValue,
    required this.minOrderAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.applicableProductIds,
    this.applicableProductNames,
  });

  factory CashCouponModel.fromJson(Map<String, dynamic> json) {
    return CashCouponModel(
      couponId: json['couponId'] ?? json['coupon_id'] ?? 0,
      couponName: json['couponName'] ?? json['coupon_name'] ?? '',
      type: json['type'] == 2 ? CashCouponType.percent : CashCouponType.fixed,
      discountValue: json['discountValue'] ?? json['discount_value'] ?? 0,
      minOrderAmount: json['minOrderAmount'] ?? json['min_order_amount'] ?? 0,
      startDate: DateTime.tryParse(json['startDate'] ?? json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? json['end_date'] ?? '') ?? DateTime.now(),
      status: _parseStatus(json['status']),
      applicableProductIds: json['applicableProductIds'] != null
          ? List<int>.from(json['applicableProductIds'])
          : null,
      applicableProductNames: json['applicableProductNames'] ?? json['applicable_product_names'],
    );
  }

  static CashCouponStatus _parseStatus(dynamic status) {
    if (status == null) return CashCouponStatus.available;
    if (status is String) {
      return switch (status.toLowerCase()) {
        'used' => CashCouponStatus.used,
        'expired' => CashCouponStatus.expired,
        _ => CashCouponStatus.available,
      };
    }
    if (status is int) {
      return switch (status) {
        1 => CashCouponStatus.available,
        2 => CashCouponStatus.used,
        3 => CashCouponStatus.expired,
        _ => CashCouponStatus.available,
      };
    }
    return CashCouponStatus.available;
  }

  bool get isAvailable => status == CashCouponStatus.available;

  double get discountValueYuan => discountValue / 100;

  double get minOrderAmountYuan => minOrderAmount / 100;

  String get discountDisplay {
    if (type == CashCouponType.fixed) {
      return '¥${discountValueYuan.toStringAsFixed(2)}';
    } else {
      return '$discountValue%';
    }
  }

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
  List<Object?> get props => [couponId];
}