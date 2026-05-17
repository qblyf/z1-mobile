import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/member_model.dart';

abstract class RetailMemberRemoteDataSource {
  Future<Result<List<MemberModel>>> searchMembersByPhone(String phone);
  Future<Result<List<MemberModel>>> getRecentMembers({int pageSize = 10});
}

class RetailMemberRemoteDataSourceImpl implements RetailMemberRemoteDataSource {
  final ApiClient apiClient;

  RetailMemberRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<MemberModel>>> searchMembersByPhone(String phone) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.memberSearchByPhones,
      queryParameters: {'phone': phone},
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => MemberModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<List<MemberModel>>> getRecentMembers({int pageSize = 10}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.memberSearchByPhones,
      queryParameters: {'pageSize': pageSize},
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => MemberModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}