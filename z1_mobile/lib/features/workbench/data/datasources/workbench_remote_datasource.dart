import 'package:z1_mobile/core/api/api_client.dart';
import 'package:z1_mobile/core/api/result.dart';
import 'package:z1_mobile/core/api/api_endpoints.dart';
import 'package:z1_mobile/types/api/dashboard-types.dart' hide Result;
import '../models/workbench_models.dart';

abstract class WorkbenchRemoteDataSource {
  Future<Result<TodayStat>> getTodayStat();
  Future<Result<int>> getApprovalCount();
  Future<Result<List<WorkbenchApprovalItem>>> getPendingApprovalList({int limit = 3});
  Future<Result<List<WorkbenchTaskItem>>> getPendingTaskList({int limit = 3});
}

class WorkbenchRemoteDataSourceImpl implements WorkbenchRemoteDataSource {
  final ApiClient apiClient;

  WorkbenchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<TodayStat>> getTodayStat() async {
    final response = await apiClient.z1func<Map<String, dynamic>>(
      ApiEndpoints.shopSaleCount(),
      parser: (data) => data,
    );

    return response.map((data) {
      return TodayStat.fromJson(data);
    });
  }

  @override
  Future<Result<int>> getApprovalCount() async {
    final response = await apiClient.z1func<Map<String, dynamic>>(
      ApiEndpoints.approvalCount,
      queryParameters: {'status': 'to-audit'},
      parser: (data) => data,
    );

    return response.map((data) {
      return data['count'] as int? ?? 0;
    });
  }

  @override
  Future<Result<List<WorkbenchApprovalItem>>> getPendingApprovalList({int limit = 3}) async {
    final response = await apiClient.z1func<Map<String, dynamic>>(
      ApiEndpoints.approvalList,
      queryParameters: {
        'status': 'to-audit',
        'limit': limit,
        'offset': 0,
      },
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['list'] as List<dynamic>? ?? [];
      return list
          .map((json) => WorkbenchApprovalItem.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Result<List<WorkbenchTaskItem>>> getPendingTaskList({int limit = 3}) async {
    final response = await apiClient.z1func<Map<String, dynamic>>(
      ApiEndpoints.taskList,
      queryParameters: {
        'status': 'pending',
        'limit': limit,
        'offset': 0,
      },
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['list'] as List<dynamic>? ?? [];
      return list
          .map((json) => WorkbenchTaskItem.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }
}