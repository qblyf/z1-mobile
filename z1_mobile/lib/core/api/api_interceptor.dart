import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import 'api_error.dart';

/// Token 拦截器 - 自动处理 Token 刷新
class TokenInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final Future<void> Function()? onUnauthorized;

  TokenInterceptor({
    required this.dio,
    required this.secureStorage,
    this.onUnauthorized,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 从安全存储获取 Token
    final accessToken = await secureStorage.read(key: AppConstants.accessTokenKey);
    final refreshToken = await secureStorage.read(key: AppConstants.refreshTokenKey);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token 过期，尝试刷新
      final refreshToken = await secureStorage.read(key: AppConstants.refreshTokenKey);

      if (refreshToken != null) {
        try {
          final response = await _refreshToken(refreshToken);
          if (response != null) {
            // 重新保存新 Token
            await secureStorage.write(
              key: AppConstants.accessTokenKey,
              value: response['access_token'],
            );
            await secureStorage.write(
              key: AppConstants.refreshTokenKey,
              value: response['refresh_token'],
            );

            // 重试原请求
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${response['access_token']}';
            final retryResponse = await dio.fetch(opts);
            handler.resolve(retryResponse);
            return;
          }
        } catch (_) {
          // 刷新失败，清除 Token
          await _clearTokens();
        }
      }

      // 未授权回调
      if (onUnauthorized != null) {
        await onUnauthorized!();
      }
    }

    handler.next(err);
  }

  Future<Map<String, dynamic>?> _refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '${ApiConstants.apiPrefix}${ApiConstants.refreshToken}',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': ''}),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearTokens() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    await secureStorage.delete(key: AppConstants.tokenExpiryKey);
  }
}

/// 日志拦截器
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      print('[API Request] ${options.method} ${options.uri}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      print('[API Response] ${response.statusCode} ${response.requestOptions.uri}');
      print('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      print('[API Error] ${err.type} ${err.requestOptions.uri}');
      print('Message: ${err.message}');
    }
    handler.next(err);
  }
}