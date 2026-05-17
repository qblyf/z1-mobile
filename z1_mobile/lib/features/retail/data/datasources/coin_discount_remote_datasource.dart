import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';

abstract class CoinDiscountRemoteDataSource {
  Future<Result<CoinDiscountResult>> calculateCoinDiscount({
    required int customerIdent,
    required int coins,
    required int orderAmount,
  });
}

class CoinDiscountResult {
  final int coins;
  final int discountAmount;

  const CoinDiscountResult({
    required this.coins,
    required this.discountAmount,
  });

  factory CoinDiscountResult.fromJson(Map<String, dynamic> json) {
    return CoinDiscountResult(
      coins: json['coins'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
    );
  }
}

class CoinDiscountRemoteDataSourceImpl implements CoinDiscountRemoteDataSource {
  final ApiClient apiClient;

  CoinDiscountRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<CoinDiscountResult>> calculateCoinDiscount({
    required int customerIdent,
    required int coins,
    required int orderAmount,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.memberExperienceEdit,
      data: {
        'customerIdent': customerIdent,
        'coins': coins,
        'orderAmount': orderAmount,
      },
      parser: (data) => data,
    );

    return response.map((data) {
      return CoinDiscountResult.fromJson(data['data'] as Map<String, dynamic>? ?? {});
    });
  }
}