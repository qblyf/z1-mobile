import 'package:equatable/equatable.dart';

/// 订单状态枚举（展示层）
///
/// 展示层把协议层 5 个状态压缩为 UI 的 3 个状态：
///
/// | 后端 status (int) | 含义       | 展示层枚举            |
/// |-------------------|-----------|----------------------|
/// | 1                 | 已发货已付款 | OrderStatus.completed |
/// | 2                 | 已发货未付款 | OrderStatus.pending   |
/// | 3                 | 未发货未付款 | OrderStatus.pending   |
/// | 4                 | 未发货已付款 | OrderStatus.pending   |
/// | 5                 | 取消        | OrderStatus.refunded  |
///
/// 协议层枚举见 `lib/types/api/order-types.dart` 中的 `OrderStatus`。
/// 此处压缩是 UI 决策（仅展示 完成/进行中/退款），勿在不了解时还原。
enum OrderStatus {
  pending('pending', '待处理'),
  completed('completed', '已完成'),
  refunded('refunded', '已退款');

  final String value;
  final String label;
  const OrderStatus(this.value, this.label);

  /// 按后端 int 值转换
  static OrderStatus fromValue(int? value) {
    switch (value) {
      case 1:
        return OrderStatus.completed; // 已发货已付款
      case 2:
        return OrderStatus.pending; // 已发货未付款
      case 3:
        return OrderStatus.pending; // 未发货未付款
      case 4:
        return OrderStatus.pending; // 未发货已付款
      case 5:
        return OrderStatus.refunded; // 取消
      default:
        return OrderStatus.pending;
    }
  }

  /// 兼容旧 String 格式（保留以防列表页仍用字符串）
  static OrderStatus fromString(String? status) {
    switch (status) {
      case 'completed':
        return OrderStatus.completed;
      case 'refunded':
        return OrderStatus.refunded;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel extends Equatable {
  final int id; // 订单ID（后端字段 orderID）
  final String orderNumber;
  final int createdAt;
  /// 会员名称（需单独调用 /members/specified 获取，这里置空）
  final String customerName;
  /// 订单原价金额（单位：分）
  final int orderAmount;
  /// 优惠金额（单位：分）
  final int discountAmount;
  /// 实付金额（单位：分）
  final int? revenueAmount;
  /// 最终金额（兼容旧字段，单位：分）
  final int finalAmount;
  /// 状态（后端返回 int，1/2/3/4/5）
  final int status;
  /// 积分增加
  final int? incCoins;
  /// 积分扣减
  final int? decCoins;
  /// 会员标识（用于查询会员信息）
  final int? customerIdent;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    this.customerName = '',
    this.orderAmount = 0,
    this.discountAmount = 0,
    this.revenueAmount,
    required this.finalAmount,
    required this.status,
    this.incCoins,
    this.decCoins,
    this.customerIdent,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['orderID'] as int? ?? 0,
        orderNumber: json['orderNumber'] as String? ?? '',
        createdAt: json['createdAt'] as int? ?? 0,
        // customerName 需单独调用 /members/specified 获取，此处置空
        customerName: '',
        orderAmount: json['orderAmount'] as int? ?? 0,
        discountAmount: json['discountAmount'] as int? ?? 0,
        revenueAmount: json['revenueAmount'] as int?,
        finalAmount: json['finalAmount'] as int? ??
            json['orderAmount'] as int? ??
            0,
        status: json['status'] as int? ?? 3,
        incCoins: json['incCoins'] as int?,
        decCoins: json['decCoins'] as int?,
        customerIdent: json['customerIdent'] as int?,
      );

  double get finalAmountYuan => finalAmount / 100;

  OrderStatus get statusEnum => OrderStatus.fromValue(status);

  String get statusLabel => statusEnum.label;

  String get timeAgo {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - createdAt;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return '${diff ~/ 60}分钟前';
    if (diff < 86400) return '${diff ~/ 3600}小时前';
    return '${diff ~/ 86400}天前';
  }

  /// 复制并更新 customerName
  OrderModel copyWithCustomerName(String name) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      createdAt: createdAt,
      customerName: name,
      orderAmount: orderAmount,
      discountAmount: discountAmount,
      revenueAmount: revenueAmount,
      finalAmount: finalAmount,
      status: status,
      incCoins: incCoins,
      decCoins: decCoins,
      customerIdent: customerIdent,
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, createdAt, status];
}
