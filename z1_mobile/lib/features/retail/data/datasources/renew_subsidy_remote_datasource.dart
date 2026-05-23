import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/renew_subsidy_model.dart';

/// 换新补贴数据源接口
abstract class RenewSubsidyRemoteDataSource {
  /// 获取可用换新补贴券列表
  Future<Result<List<RenewSubsidyModel>>> getAvailableRenewSubsidies();
  /// 按分类获取可用换新补贴券
  Future<Result<List<RenewSubsidyModel>>> getAvailableCouponClass(String classId);
  /// 获取券分类列表
  Future<Result<List<CouponClassModel>>> getCouponClassList();
}

class RenewSubsidyRemoteDataSourceImpl implements RenewSubsidyRemoteDataSource {
  final ApiClient apiClient;

  RenewSubsidyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<RenewSubsidyModel>>> getAvailableRenewSubsidies() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.availableRenewSubsidy,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list
          .map((e) => RenewSubsidyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Result<List<RenewSubsidyModel>>> getAvailableCouponClass(String classId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.availableCouponClass(classId),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list
          .map((e) => RenewSubsidyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Result<List<CouponClassModel>>> getCouponClassList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.couponClassList,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list
          .map((e) => CouponClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}