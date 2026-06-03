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
    // 调用 /order/shop-sale-list?number=XXX，返回结构 {data: [...]} 或 {list: [...]}
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.shopSaleInfoByNumber(orderNumber),
      parser: (data) => data,
    );

    // 先解析订单
    final order = response.fold(
      (failure) => null,
      (data) {
        // 兼容两种响应格式
        final List<dynamic> orderList = data['data'] as List<dynamic>? ??
            data['list'] as List<dynamic>? ??
            [];
        if (orderList.isEmpty) return null;
        return OrderModel.fromJson(
            orderList.first as Map<String, dynamic>);
      },
    );

    if (order == null) {
      return Failure(ApiFailure.serverError('订单不存在'));
    }

    // 如果有 customerIdent，异步查询会员名称
    if (order.customerIdent != null && order.customerIdent != 0) {
      return _fetchMemberName(order);
    }

    return Success(order);
  }

  /// 查询会员名称并填充到 OrderModel
  Future<Result<OrderModel>> _fetchMemberName(OrderModel order) async {
    try {
      final memberResp = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.memberSpecifiedPath,
        queryParameters: {'userIdents': order.customerIdent!.toString()},
        parser: (data) => data,
      );

      final updatedOrder = memberResp.fold(
        (failure) => null,
        (data) {
          final list = data['list'] as List<dynamic>? ?? [];
          if (list.isEmpty) return null;
          final memberName = list.first['name'] as String? ?? '';
          return order.copyWithCustomerName(memberName);
        },
      );

      return Success(updatedOrder ?? order);
    } catch (_) {
      return Success(order); // 异常不阻塞订单展示
    }
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
