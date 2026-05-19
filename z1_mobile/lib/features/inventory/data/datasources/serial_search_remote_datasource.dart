import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/serial_search_model.dart';
import '../models/stocktaking_model.dart';

class SerialSearchParams extends Equatable {
  final String code;
  final int? warehouseId;

  const SerialSearchParams({
    required this.code,
    this.warehouseId,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'code': code,
      if (warehouseId != null) 'warehouseID': warehouseId,
    };
  }

  @override
  List<Object?> get props => [code, warehouseId];
}

abstract class SerialSearchRemoteDataSource {
  Future<Result<SerialSearchResultModel>> searchSerial(SerialSearchParams params);
  Future<Result<List<WarehouseModel>>> getWarehouseList();
}

class SerialSearchRemoteDataSourceImpl implements SerialSearchRemoteDataSource {
  final ApiClient apiClient;

  SerialSearchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<SerialSearchResultModel>> searchSerial(SerialSearchParams params) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.serialSearchFullMatch,
      data: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      return SerialSearchResultModel.fromJson(data['data'] as Map<String, dynamic>? ?? {});
    });
  }

  Future<Result<SerialSearchResultModel>> searchSerialFuzzy(SerialSearchParams params) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.serialSearch,
      data: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      return SerialSearchResultModel.fromJson(data['data'] as Map<String, dynamic>? ?? {});
    });
  }

  @override
  Future<Result<List<WarehouseModel>>> getWarehouseList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.warehouseListCondition(state: 1),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data']['list'] as List<dynamic>? ?? [];
      return list
          .map((json) => WarehouseModel.fromJson(json as Map<String, dynamic>))
          .where((w) => !w.name.contains('test') && !w.name.contains('测试'))
          .toList();
    });
  }
}