import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/cash_coupon_model.dart';

/// 代金券数据源接口
abstract class CashCouponRemoteDataSource {
  /// 获取可用代金券列表
  Future<Result<List<CashCouponModel>>> getAvailableCashCoupons();
  /// 获取会员持有的代金券列表
  Future<Result<List<CashCouponModel>>> getCashCouponList();
}

class CashCouponRemoteDataSourceImpl implements CashCouponRemoteDataSource {
  final ApiClient apiClient;

  CashCouponRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<CashCouponModel>>> getAvailableCashCoupons() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.availableCashCoupons,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list
          .map((e) => CashCouponModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Result<List<CashCouponModel>>> getCashCouponList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.cashCouponList,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list
          .map((e) => CashCouponModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}