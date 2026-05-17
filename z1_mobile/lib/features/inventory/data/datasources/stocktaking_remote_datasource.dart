import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/stocktaking_model.dart';

class StocktakingListParams extends Equatable {
  final int page;
  final int pageSize;
  final List<int>? states;

  const StocktakingListParams({
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

abstract class StocktakingRemoteDataSource {
  Future<Result<List<StocktakingModel>>> getStocktakingList(StocktakingListParams params);
  Future<Result<StocktakingModel>> getStocktakingDetail(int id);
  Future<Result<List<StocktakingProductModel>>> getStocktakingProducts(int id);
  Future<Result<int>> addStocktaking({required int warehouseID, String? remarks});
  Future<Result<void>> endStocktaking(int id);
  Future<Result<void>> restartStocktaking(int id);
  Future<Result<List<WarehouseModel>>> getWarehouseList();
}

class StocktakingRemoteDataSourceImpl implements StocktakingRemoteDataSource {
  final ApiClient apiClient;

  StocktakingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<StocktakingModel>>> getStocktakingList(
      StocktakingListParams params) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.stocktakingList(page: params.page, pageSize: params.pageSize),
      queryParameters: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => StocktakingModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<StocktakingModel>> getStocktakingDetail(int id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.stocktakingDetail(id),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      if (list.isEmpty) {
        return StocktakingModel(
          id: id,
          warehouseID: 0,
          state: StocktakingState.draft,
          createdAt: 0,
          createdBy: 0,
        );
      }
      return StocktakingModel.fromJson(list.first as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<List<StocktakingProductModel>>> getStocktakingProducts(int id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.stocktakingProducts(id),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => StocktakingProductModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<int>> addStocktaking({required int warehouseID, String? remarks}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.stocktakingAdd,
      data: <String, dynamic>{
        'warehouseID': warehouseID,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
      parser: (data) => data,
    );

    return response.map((data) {
      return data['data']['id'] as int? ?? 0;
    });
  }

  @override
  Future<Result<void>> endStocktaking(int id) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.stocktakingEnd(id),
      data: {},
      parser: (data) => data,
    );

    return response.map((data) => null);
  }

  @override
  Future<Result<void>> restartStocktaking(int id) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.stocktakingRestart(id),
      data: {},
      parser: (data) => data,
    );

    return response.map((data) => null);
  }

  @override
  Future<Result<List<WarehouseModel>>> getWarehouseList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.warehouseList(state: 1),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => WarehouseModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}