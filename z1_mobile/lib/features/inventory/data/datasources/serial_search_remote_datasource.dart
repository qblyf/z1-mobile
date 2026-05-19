import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/serial_search_model.dart';
import '../models/stocktaking_model.dart';

class SerialSearchParams extends Equatable {
  final String serial;
  final int? warehouseId;

  const SerialSearchParams({
    required this.serial,
    this.warehouseId,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'serial': serial,
      if (warehouseId != null) 'state': warehouseId,
    };
  }

  @override
  List<Object?> get props => [serial, warehouseId];
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
      ApiEndpoints.serialSearch,
      data: {'serial': params.serial, if (params.warehouseId != null) 'state': params.warehouseId},
      parser: (data) => data,
    );

    return response.map((data) {
      return SerialSearchResultModel.fromJson(data['data'] as Map<String, dynamic>? ?? {});
    });
  }

  Future<Result<SerialSearchResultModel>> searchSerialFullMatch(SerialSearchParams params) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.serialSearchFullMatch,
      data: {'serials': [params.serial]},
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