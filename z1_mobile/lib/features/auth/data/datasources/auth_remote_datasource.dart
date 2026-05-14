import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/repositories/auth_repository.dart';

/// 远程数据源接口
abstract class AuthRemoteDataSource {
  /// 登录
  Future<Map<String, dynamic>> login(String account, String password);

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo();

  /// 刷新 Token
  Future<Map<String, dynamic>> refreshToken(String refreshToken);

  /// 登出
  Future<void> logout();
}

/// 远程数据源实现
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String phone, String pwd) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {
        'phone': phone,
        'pwd': pwd,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await apiClient.get(ApiConstants.userSelf);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiConstants.logout);
  }
}