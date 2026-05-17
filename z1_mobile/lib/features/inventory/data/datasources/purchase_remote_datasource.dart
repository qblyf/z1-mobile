import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/purchase_model.dart';

class PurchaseListParams extends Equatable {
  final int page;
  final int pageSize;
  final List<int>? states;

  const PurchaseListParams({
    this.page = 1,
    this.pageSize = 20,
    this.states,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (states != null && states!.isNotEmpty) 'states[]': states,
    };
  }

  @override
  List<Object?> get props => [page, pageSize, states];
}

abstract class PurchaseRemoteDataSource {
  Future<Result<List<PurchaseModel>>> getPurchaseList(PurchaseListParams params);
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  final ApiClient apiClient;

  PurchaseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<PurchaseModel>>> getPurchaseList(PurchaseListParams params) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.purchaseList,
      queryParameters: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => PurchaseModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}