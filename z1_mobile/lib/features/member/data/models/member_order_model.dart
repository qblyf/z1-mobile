import 'package:equatable/equatable.dart';

// OrderStatus 由订单领域模型统一定义，此处复用避免重复
import '../../../order/data/models/order_model.dart' show OrderStatus;
export '../../../order/data/models/order_model.dart' show OrderStatus;

class MemberOrderModel extends Equatable {
  final String orderNumber;
  final int createdAt;
  final String customerName;
  final int finalAmount;
  final String status;

  const MemberOrderModel({
    required this.orderNumber,
    required this.createdAt,
    required this.customerName,
    required this.finalAmount,
    required this.status,
  });

  factory MemberOrderModel.fromJson(Map<String, dynamic> json) => MemberOrderModel(
        orderNumber: json['orderNumber'] as String? ?? '',
        createdAt: json['createdAt'] as int? ?? 0,
        customerName: json['customerName'] as String? ?? '',
        finalAmount: json['finalAmount'] as int? ?? 0,
        // 后端 status 可能是 int（1-5）或 String（pending/completed/refunded）
        // 统一在解析期归一为协议层 String 值（OrderStatus.value），避免运行时 cast 崩溃
        status: _parseStatus(json['status']),
      );

  static String _parseStatus(dynamic raw) {
    if (raw is int) return OrderStatus.fromValue(raw).value;
    if (raw is String) return OrderStatus.fromString(raw).value;
    return OrderStatus.pending.value;
  }

  double get finalAmountYuan => finalAmount / 100;

  OrderStatus get statusEnum => OrderStatus.fromString(status);

  String get statusLabel => statusEnum.label;

  String get timeAgo {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - createdAt;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return '${diff ~/ 60}分钟前';
    if (diff < 86400) return '${diff ~/ 3600}小时前';
    return '${diff ~/ 86400}天前';
  }

  String get createdAtFormatted {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [orderNumber, createdAt, status];
}