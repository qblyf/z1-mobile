import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/transfer_model.dart';

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

abstract class TransferRemoteDataSource {
  Future<Result<List<TransferModel>>> getTransferList(TransferListParams params);
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
}