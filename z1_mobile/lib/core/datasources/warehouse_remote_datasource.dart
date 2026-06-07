import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/result.dart';
import '../models/warehouse_model.dart';

/// 仓库列表数据源（共享）。
/// 解析约定与 inventory 各页一致：res 体为 {code, data:{list:[...]}}，过滤测试仓。
abstract class WarehouseRemoteDataSource {
  Future<Result<List<WarehouseModel>>> getWarehouseList();
}

class WarehouseRemoteDataSourceImpl implements WarehouseRemoteDataSource {
  final ApiClient apiClient;

  WarehouseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<WarehouseModel>>> getWarehouseList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.warehouseListCondition(state: 1),
      parser: (data) => data as Map<String, dynamic>,
    );

    return response.map((data) {
      final list = data['data']?['list'] as List<dynamic>? ?? [];
      return list
          .map((json) => WarehouseModel.fromJson(json as Map<String, dynamic>))
          .where((w) => !w.name.contains('test') && !w.name.contains('测试'))
          .toList();
    });
  }
}
