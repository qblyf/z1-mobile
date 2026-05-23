import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/recycle_order_model.dart';

/// 回收单数据源接口
abstract class RecycleOrderRemoteDataSource {
  /// 获取可绑定回收单列表
  Future<Result<List<RecycleOrderModel>>> getAllowBindList();
  /// 校验回收单是否可关联
  Future<Result<bool>> checkAhsOrder(int ahsOrderId);
}

/// 回收单数据源实现
class RecycleOrderRemoteDataSourceImpl implements RecycleOrderRemoteDataSource {
  final ApiClient apiClient;

  RecycleOrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<RecycleOrderModel>>> getAllowBindList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.allowBindAhsOrderList,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list
          .map((e) => RecycleOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Result<bool>> checkAhsOrder(int ahsOrderId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.checkAhsOrder(ahsOrderId),
      parser: (data) => data,
    );

    return response.map((data) {
      // 校验接口通常返回 { code: 10000, data: true/false }
      final result = data['data'] as bool? ?? data['success'] as bool? ?? true;
      return result;
    });
  }
}
