import 'package:equatable/equatable.dart';

enum CouponType {
  fixed, // 固定金额
  percent, // 百分比折扣
}

enum CouponStatus {
  available,
  used,
  expired,
}

class CouponModel extends Equatable {
  final int couponId;
  final String couponName;
  final CouponType type;
  final int discountValue; // 优惠金额或折扣率
  final int minOrderAmount; // 最低订单金额（分）
  final DateTime startDate;
  final DateTime endDate;
  final CouponStatus status;
  final List<int>? applicableProductIds; // 适用商品ID列表，null表示全部适用
  final String? applicableProductNames; // 适用商品名称

  const CouponModel({
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

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      couponId: json['couponId'] ?? json['coupon_id'] ?? 0,
      couponName: json['couponName'] ?? json['coupon_name'] ?? '',
      type: json['type'] == 2 ? CouponType.percent : CouponType.fixed,
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

  static CouponStatus _parseStatus(dynamic status) {
    if (status == null) return CouponStatus.available;
    if (status is String) {
      return switch (status.toLowerCase()) {
        'used' => CouponStatus.used,
        'expired' => CouponStatus.expired,
        _ => CouponStatus.available,
      };
    }
    if (status is int) {
      return switch (status) {
        1 => CouponStatus.available,
        2 => CouponStatus.used,
        3 => CouponStatus.expired,
        _ => CouponStatus.available,
      };
    }
    return CouponStatus.available;
  }

  bool get isAvailable => status == CouponStatus.available;

  double get discountValueYuan => discountValue / 100;

  double get minOrderAmountYuan => minOrderAmount / 100;

  String get discountDisplay {
    if (type == CouponType.fixed) {
      return '¥${discountValueYuan.toStringAsFixed(2)}';
    } else {
      return '${discountValue}%';
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