import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/order_model.dart';
import '../models/order_product_model.dart';

abstract class OrderDetailRemoteDataSource {
  Future<Result<OrderModel>> getOrderByNumber(String orderNumber);
  Future<Result<List<OrderProductModel>>> getOrderProducts(int orderId);
}

class OrderDetailRemoteDataSourceImpl implements OrderDetailRemoteDataSource {
  final ApiClient apiClient;

  OrderDetailRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<OrderModel>> getOrderByNumber(String orderNumber) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.shopSaleInfoByNumber(orderNumber),
      parser: (data) => data,
    );

    return response.map((data) => OrderModel.fromJson(data));
  }

  @override
  Future<Result<List<OrderProductModel>>> getOrderProducts(int orderId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.shopSaleInfo(orderId),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((json) => OrderProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }
}