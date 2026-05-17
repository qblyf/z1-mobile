import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/member_model.dart';
import '../models/member_order_model.dart';

abstract class MemberRemoteDataSource {
  Future<Result<List<MemberModel>>> searchByPhone(String keyword);
  Future<Result<MemberModel>> getMemberDetail(int memberId);
  Future<Result<List<MemberOrderModel>>> getMemberOrders(int memberId, {int page = 1, int pageSize = 20});
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final ApiClient _apiClient;

  MemberRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Result<List<MemberModel>>> searchByPhone(String keyword) async {
    return _apiClient.get<List<MemberModel>>(
      ApiEndpoints.memberSearchByPhones,
      queryParameters: {'keyword': keyword},
      parser: (data) {
        final list = data['data'] as List<dynamic>? ?? [];
        return list.map((e) => MemberModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<Result<MemberModel>> getMemberDetail(int memberId) async {
    return _apiClient.get<MemberModel>(
      ApiEndpoints.memberDetail(memberId),
      parser: (data) {
        return MemberModel.fromJson(data['data'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<Result<List<MemberOrderModel>>> getMemberOrders(int memberId, {int page = 1, int pageSize = 20}) async {
    return _apiClient.get<List<MemberOrderModel>>(
      ApiEndpoints.shopSaleList,
      queryParameters: {
        'memberId': memberId.toString(),
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      parser: (data) {
        final list = data['data'] as List<dynamic>? ?? [];
        return list.map((e) => MemberOrderModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
}