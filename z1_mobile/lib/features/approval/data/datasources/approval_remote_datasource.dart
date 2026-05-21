import 'package:equatable/equatable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/approval_model.dart';

enum ApprovalTab { all, toAudit, audited, rejected }

class ApprovalListParams extends Equatable {
  final ApprovalTab tab;
  final int page;
  final int pageSize;
  final String? approvalTypes;
  final String? platforms;

  const ApprovalListParams({
    this.tab = ApprovalTab.all,
    this.page = 1,
    this.pageSize = 20,
    this.approvalTypes,
    this.platforms,
  });

  String? get statusParam {
    switch (tab) {
      case ApprovalTab.all:
        return null;
      case ApprovalTab.toAudit:
        return 'to-audit';
      case ApprovalTab.audited:
        return 'audited';
      case ApprovalTab.rejected:
        return 'rejected';
    }
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (statusParam != null) 'status': statusParam,
      if (approvalTypes != null) 'approvalTypes': approvalTypes,
      if (platforms != null) 'platforms': platforms,
      'limit': pageSize,
      'offset': (page - 1) * pageSize,
      'orderBy': 'createdAt:DESC',
    };
  }

  @override
  List<Object?> get props => [tab, page, pageSize, approvalTypes, platforms];
}

abstract class ApprovalRemoteDataSource {
  Future<Result<List<ApprovalModel>>> getApprovalList(ApprovalListParams params);
  Future<Result<int>> getApprovalCount({String? status});
}

class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {
  final ApiClient apiClient;

  ApprovalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<ApprovalModel>>> getApprovalList(
      ApprovalListParams params) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.approvalList,
      queryParameters: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((json) => ApprovalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Result<int>> getApprovalCount({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.approvalCount,
      queryParameters: params,
      parser: (data) => data,
    );

    return response.map((data) => data['count'] as int? ?? 0);
  }
}