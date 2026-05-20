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
    // 后端参数名是 phones（复数），支持逗号分隔的多个手机号
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.memberSearchByPhones,
      queryParameters: {'phones': phone},
      parser: (data) => data,
    );

    return response.map((data) {
      // 后端返回结构是 { code, res: [...] }
      final list = (data['res'] as List<dynamic>?) ?? [];
      return list.map((json) => MemberModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<List<MemberModel>>> getRecentMembers({int pageSize = 10}) async {
    // 注意：/members/list-phones 不支持 pageSize 参数
    // 需要使用 /members/list 接口获取会员列表
    // 但为了保持兼容性，这里使用 /members/list 并按时间排序
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.memberList(pageSize: pageSize),
      parser: (data) => data,
    );

    return response.map((data) {
      // /members/list 返回结构是 { code, list: [...] }
      final list = (data['list'] as List<dynamic>?) ?? [];
      return list.map((json) => MemberModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}