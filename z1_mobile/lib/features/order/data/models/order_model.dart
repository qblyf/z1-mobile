import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending('pending', '待处理'),
  completed('completed', '已完成'),
  refunded('refunded', '已退款');

  final String value;
  final String label;
  const OrderStatus(this.value, this.label);

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
  final int id;
  final String orderNumber;
  final int createdAt;
  final String customerName;
  final int finalAmount;
  final String status;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.customerName,
    required this.finalAmount,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int? ?? 0,
        orderNumber: json['orderNumber'] as String? ?? '',
        createdAt: json['createdAt'] as int? ?? 0,
        customerName: json['customerName'] as String? ?? '',
        finalAmount: json['finalAmount'] as int? ?? 0,
        status: json['status'] as String? ?? 'pending',
      );

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

  @override
  List<Object?> get props => [id, orderNumber, createdAt, status];
}