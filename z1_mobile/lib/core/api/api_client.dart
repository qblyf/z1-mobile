import 'package:dio/dio.dart';
import '../services/token_service.dart';
import 'api_endpoints.dart';
import 'result.dart';

/// API 拦截器
/// 自动添加 Token、处理错误
class ApiInterceptor extends Interceptor {
  final TokenService _tokenService;
  final String _baseUrl;

  ApiInterceptor({required TokenService tokenService, required String baseUrl})
      : _tokenService = tokenService,
        _baseUrl = baseUrl;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 添加 Authorization header
    final token = _tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 添加 Use-Permissions header（用于权限验证）
    // TODO: 从配置获取 permission token

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token 过期，尝试刷新
      final refreshed = await _refreshToken();
      if (refreshed) {
        // 重新发起请求
        final retryResponse = await _retry(err.requestOptions);
        handler.resolve(retryResponse);
        return;
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _tokenService.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: _getBaseUrl()));
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        if (newAccessToken != null) {
          await _tokenService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );
          return true;
        }
      }
    } catch (e) {
      // 刷新失败
    }
    return false;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = _tokenService.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    final dio = Dio(BaseOptions(baseUrl: _getBaseUrl()));
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  String _getBaseUrl() {
    return _baseUrl;
  }
}

/// API 客户端
class ApiClient {
  final Dio _dio;
  final TokenService _tokenService;
  final String _baseUrl;

  ApiClient({
    required Dio dio,
    required TokenService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService,
        _baseUrl = dio.options.baseUrl {
    _dio.interceptors.add(ApiInterceptor(tokenService: tokenService, baseUrl: _baseUrl));
  }

  /// GET 请求
  Future<Result<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, parser);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// POST 请求
  Future<Result<T>> post<T>(
    String url, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(url, data: data);
      return _parseResponse(response, parser);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Result<T> _parseResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    final data = response.data;

    if (data == null) {
      return Failure(ApiFailure.serverError('空响应'));
    }

    if (parser != null) {
      try {
        return Success(parser(data));
      } catch (e) {
        return Failure(ApiFailure.serverError('解析失败: $e'));
      }
    }

    // 默认返回 data
    return Success(data as T);
  }

  Result<T> _handleError<T>(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = _extractErrorMessage(e.response?.data);

    switch (statusCode) {
      case 400:
        return Failure(ApiFailure.validationError(message));
      case 401:
        return Failure(ApiFailure.unauthorized(message));
      case 500:
      case null:
        return Failure(ApiFailure.serverError(message));
      default:
        return Failure(ApiFailure.unknown(message));
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return '请求失败';
    if (data is Map) {
      return data['message'] ?? data['msg'] ?? data['error'] ?? '请求失败';
    }
    return '请求失败';
  }

  /// 设置 Base URL
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// 获取 Token 服务
  TokenService get tokenService => _tokenService;
}