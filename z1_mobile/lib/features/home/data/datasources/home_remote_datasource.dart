import '../../../../core/api/api_client.dart';
import '../../../../core/api/result.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/order_model.dart';

/// 首页远程数据源
abstract class HomeRemoteDataSource {
  /// 获取订单列表
  Future<Result<List<OrderModel>>> getOrderList();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<OrderModel>>> getOrderList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.shopSaleList,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}