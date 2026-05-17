import '../../../../core/api/api_client.dart';
import '../../../../core/api/result.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../data/models/user_model.dart';

/// 远程数据源接口
abstract class AuthRemoteDataSource {
  /// 登录
  Future<Result<LoginResponse>> login(LoginRequest request);

  /// 获取用户信息
  Future<Result<AuthUser>> getUserInfo();

  /// 刷新 Token
  Future<Result<TokenModel>> refreshToken(String refreshToken);

  /// 登出
  Future<Result<void>> logout();
}

/// 远程数据源实现
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<LoginResponse>> login(LoginRequest request) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'phone': request.mobilePhone,
        'pwd': request.password,
      },
      parser: (data) => data,
    );

    // 处理 {code, res: {token}} 格式，映射为前端期望的格式
    return response.map((data) {
      final res = data['res'] as Map<String, dynamic>?;
      return LoginResponse(
        accessToken: res?['token'] as String? ?? '',
        refreshToken: res?['refresh_token'] as String?,
        expiresIn: res?['expires_in'] as int? ?? 604800,
      );
    });
  }

  @override
  Future<Result<AuthUser>> getUserInfo() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.userSelf,
      parser: (data) => data,
    );

    return response.map((data) {
      final res = data['res'] as Map<String, dynamic>? ?? {};
      return AuthUser.fromJson(res);
    });
  }

  @override
  Future<Result<TokenModel>> refreshToken(String refreshToken) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
      parser: (data) => data,
    );

    return response.map((data) => TokenModel.fromJson(data));
  }

  @override
  Future<Result<void>> logout() async {
    final response = await apiClient.post(ApiEndpoints.logout);
    return response.map((_) => {});
  }
}