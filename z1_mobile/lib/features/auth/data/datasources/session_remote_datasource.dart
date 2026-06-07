import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';

/// 登录态扩充数据源：拉取权限包 JWT 与默认仓库。
///
/// 说明（已对真实后端实测）：
/// - 员工主部门 deptID 直接在 access token JWT payload 里，无需额外接口；
///   故本数据源不查员工，只负责「权限包」与「默认仓」两个网络调用。
/// - 默认仓接口需要真实 permissionsJWT 作 Use-Permissions（'all' 无效）。
abstract class SessionRemoteDataSource {
  /// 发放权限包，返回 permissionsJWT（自带 "Bearer " 前缀）
  Future<Result<String>> grantPermissionPackage(String key);

  /// 按主部门取默认仓库 ID（取列表首个；空列表返回 null）
  Future<Result<int?>> getDefaultWarehouseByDept(
    int deptId, {
    required String permissionJwt,
  });
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final ApiClient apiClient;

  SessionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<String>> grantPermissionPackage(String key) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.permissionPackageGrant(key),
      parser: (data) => data as Map<String, dynamic>,
    );

    return response.map((data) {
      final res = data['res'] as Map<String, dynamic>?;
      return res?['permissionsJWT'] as String? ?? '';
    });
  }

  @override
  Future<Result<int?>> getDefaultWarehouseByDept(
    int deptId, {
    required String permissionJwt,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.warehouseIdsByMainDept(deptId),
      headers: {'Use-Permissions': permissionJwt},
      parser: (data) => data as Map<String, dynamic>,
    );

    return response.map((data) {
      final list = (data['list'] as List<dynamic>?)?.cast<int>() ?? const [];
      return list.isNotEmpty ? list.first : null;
    });
  }
}
