import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/order_model.dart';

enum DateRange { today, week, month, all }

class OrderListParams extends Equatable {
  final int page;
  final int pageSize;
  final DateRange dateRange;
  final int? warehouseID;

  const OrderListParams({
    this.page = 1,
    this.pageSize = 20,
    this.dateRange = DateRange.today,
    this.warehouseID,
  });

  Map<String, dynamic> toQueryParams() {
    final now = DateTime.now();
    int? startTime;

    switch (dateRange) {
      case DateRange.today:
        final todayStart = DateTime(now.year, now.month, now.day);
        startTime = todayStart.millisecondsSinceEpoch ~/ 1000;
        break;
      case DateRange.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startTime = DateTime(weekStart.year, weekStart.month, weekStart.day)
            .millisecondsSinceEpoch ~/
            1000;
        break;
      case DateRange.month:
        startTime =
            DateTime(now.year, now.month, 1).millisecondsSinceEpoch ~/ 1000;
        break;
      case DateRange.all:
        startTime = null;
        break;
    }

    // 后端 shop-sale-list 用 offset/limit 分页（不认 page/pageSize），
    // 时间过滤参数名是 minCreatedAt（不认 startTime）。BLoC 仍按 page 计数，
    // 这里换算成 offset = (page-1)*pageSize。
    return {
      'offset': (page - 1) * pageSize,
      'limit': pageSize,
      if (startTime != null) 'minCreatedAt': startTime,
      if (warehouseID != null) 'warehouseID': warehouseID,
    };
  }

  @override
  List<Object?> get props => [page, pageSize, dateRange, warehouseID];
}

abstract class OrderListRemoteDataSource {
  Future<Result<List<OrderModel>>> getOrderList(OrderListParams params);
}

class OrderListRemoteDataSourceImpl implements OrderListRemoteDataSource {
  final ApiClient apiClient;

  OrderListRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<OrderModel>>> getOrderList(
      OrderListParams params) async {
    // ApiClient.get 的 _parseResponse 不解包 res，整个 {code, res} 透传给 parser。
    // shop-sale-list 的订单数组在顶层 res 里（直接是 List，无 data/list 包装）。
    final response = await apiClient.get<List<OrderModel>>(
      ApiEndpoints.shopSaleList(),
      queryParameters: params.toQueryParams(),
      parser: (data) {
        final list = (data as Map<String, dynamic>)['res'] as List<dynamic>? ?? [];
        return list
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );

    return response;
  }
}