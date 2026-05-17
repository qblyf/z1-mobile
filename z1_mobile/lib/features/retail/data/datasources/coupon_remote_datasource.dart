import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/coupon_model.dart';

abstract class CouponRemoteDataSource {
  Future<Result<List<CouponModel>>> getCoupons();
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiClient apiClient;

  CouponRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<CouponModel>>> getCoupons() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.couponSelf,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list
          .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}