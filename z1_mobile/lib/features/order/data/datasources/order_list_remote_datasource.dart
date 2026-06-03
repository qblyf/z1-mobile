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

    return {
      'page': page,
      'pageSize': pageSize,
      if (startTime != null) 'startTime': startTime,
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
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.shopSaleList(),
      queryParameters: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}