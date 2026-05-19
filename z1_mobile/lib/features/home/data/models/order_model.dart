import 'package:equatable/equatable.dart';

/// 订单模型
class OrderModel extends Equatable {
  final int orderID;
  final String orderNumber;
  final int orderAmount; // 单位：分
  final int discountAmount; // 单位：分
  final int revenueAmount; // 单位：分
  final int status;
  final int type;
  final String genre;
  final int sellerIdent;
  final int customerIdent;
  final int departmentID;
  final int createdAt; // Unix 时间戳
  final String? remarks;

  const OrderModel({
    required this.orderID,
    required this.orderNumber,
    required this.orderAmount,
    required this.discountAmount,
    required this.revenueAmount,
    required this.status,
    required this.type,
    required this.genre,
    required this.sellerIdent,
    required this.customerIdent,
    required this.departmentID,
    required this.createdAt,
    this.remarks,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        orderID: json['orderID'] as int? ?? 0,
        orderNumber: json['orderNumber'] as String? ?? '',
        orderAmount: json['orderAmount'] as int? ?? 0,
        discountAmount: json['discountAmount'] as int? ?? 0,
        revenueAmount: json['revenueAmount'] as int? ?? 0,
        status: json['status'] as int? ?? 0,
        type: json['type'] as int? ?? 0,
        genre: json['genre'] as String? ?? '',
        sellerIdent: json['sellerIdent'] as int? ?? 0,
        customerIdent: json['customerIdent'] as int? ?? 0,
        departmentID: json['departmentID'] as int? ?? 0,
        createdAt: json['createdAt'] as int? ?? 0,
        remarks: json['remarks'] as String?,
      );

  /// 订单金额（元）
  double get orderAmountYuan => orderAmount / 100;

  /// 折扣金额（元）
  double get discountAmountYuan => discountAmount / 100;

  /// 收入金额（元）
  double get revenueAmountYuan => revenueAmount / 100;

  /// 订单状态文本
  String get statusText {
    switch (status) {
      case 1:
        return '已完成';
      case 2:
        return '进行中';
      case 3:
        return '已取消';
      default:
        return '未知';
    }
  }

  /// 订单时间（相对时间）
  String get timeAgo {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - createdAt;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return '${diff ~/ 60}分钟前';
    if (diff < 86400) return '${diff ~/ 3600}小时前';
    return '${diff ~/ 86400}天前';
  }

  @override
  List<Object?> get props => [orderID, orderNumber, status];
}

/// 首页统计数据
class HomeStats extends Equatable {
  final double todaySales; // 单位：元
  final int todayOrderCount;
  final double salesGrowth; // 百分比

  const HomeStats({
    required this.todaySales,
    required this.todayOrderCount,
    this.salesGrowth = 0,
  });

  factory HomeStats.fromOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;

    // 筛选今日订单
    final todayOrders = orders.where((o) => o.createdAt >= todayStart).toList();

    final totalSales = todayOrders.fold<int>(0, (sum, o) => sum + o.orderAmount) / 100;

    return HomeStats(
      todaySales: totalSales,
      todayOrderCount: todayOrders.length,
      salesGrowth: 0, // 暂无对比数据
    );
  }

  @override
  List<Object?> get props => [todaySales, todayOrderCount];
}