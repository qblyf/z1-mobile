import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/transfer_model.dart';
import '../models/stocktaking_model.dart';

class TransferListParams extends Equatable {
  final int page;
  final int pageSize;
  final List<int>? states;

  const TransferListParams({
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

class TransferCreateParams extends Equatable {
  final int outWarehouseID;
  final int inWarehouseID;
  final List<Map<String, dynamic>> items;
  final int type;

  const TransferCreateParams({
    required this.outWarehouseID,
    required this.inWarehouseID,
    required this.items,
    this.type = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'outWarehouseID': outWarehouseID,
      'inWarehouseID': inWarehouseID,
      'items': items,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [outWarehouseID, inWarehouseID, items, type];
}

abstract class TransferRemoteDataSource {
  Future<Result<List<TransferModel>>> getTransferList(TransferListParams params);
  Future<Result<TransferDetailModel>> getTransferDetail(int id);
  Future<Result<int>> createTransfer(TransferCreateParams params);
  Future<Result<void>> shipping(int transferID, int inWarehouseID);
  Future<Result<void>> received(int transferID);
  Future<Result<List<WarehouseModel>>> getWarehouseList();
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final ApiClient apiClient;

  TransferRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<TransferModel>>> getTransferList(TransferListParams params) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.transferList,
      queryParameters: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => TransferModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<TransferDetailModel>> getTransferDetail(int id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.transferDetail(id),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      if (list.isEmpty) {
        return TransferDetailModel(
          id: id,
          fromWarehouseID: 0,
          toWarehouseID: 0,
          state: TransferState.pending,
          createdAt: 0,
          createdBy: 0,
        );
      }
      return TransferDetailModel.fromJson(list.first as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<int>> createTransfer(TransferCreateParams params) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.transferAdd,
      data: params.toJson(),
      parser: (data) => data,
    );

    return response.map((data) {
      return data['data']['id'] as int? ?? 0;
    });
  }

  @override
  Future<Result<void>> shipping(int transferID, int inWarehouseID) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.transferShipping,
      data: {'transferID': transferID, 'inWarehouseID': inWarehouseID},
      parser: (data) => data,
    );

    return response.map((data) => null);
  }

  @override
  Future<Result<void>> received(int transferID) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.transferReceived,
      data: {'transferID': transferID},
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
      final list = data['data']['list'] as List<dynamic>? ?? [];
      return list
          .map((json) => WarehouseModel.fromJson(json as Map<String, dynamic>))
          .where((w) => !w.name.contains('test') && !w.name.contains('测试'))
          .toList();
    });
  }
}