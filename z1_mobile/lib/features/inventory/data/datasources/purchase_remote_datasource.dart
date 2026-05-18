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
  Future<Result<PurchaseDetailModel>> getPurchaseDetail(int id);
  Future<Result<void>> purchaseIntoWarehouse({
    required int purchaseId,
    required int warehouseId,
    required List<Map<String, dynamic>> products,
    String? remarks,
  });
  Future<Result<List<WarehouseModel>>> getWarehouseList();
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

  @override
  Future<Result<PurchaseDetailModel>> getPurchaseDetail(int id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.purchaseDetail(id),
      parser: (data) => data,
    );

    return response.map((data) {
      return PurchaseDetailModel.fromJson(data);
    });
  }

  @override
  Future<Result<void>> purchaseIntoWarehouse({
    required int purchaseId,
    required int warehouseId,
    required List<Map<String, dynamic>> products,
    String? remarks,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseIntoWarehouse,
      data: {
        'purchaseID': purchaseId,
        'warehouseID': warehouseId,
        'products': products,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
      parser: (data) => data,
    );

    return response.map((data) => null);
  }

  @override
  Future<Result<List<WarehouseModel>>> getWarehouseList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.warehouseListCondition(state: 1),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data']['warehouses'] as List<dynamic>? ?? [];
      return list.map((json) => WarehouseModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}