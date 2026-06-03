import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import 'api_endpoints.dart';
import '../services/token_service.dart';

/// Token 拦截器 - 自动处理 Token 刷新
class TokenInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  final Future<void> Function()? onUnauthorized;

  TokenInterceptor({
    required this.dio,
    required this.tokenService,
    this.onUnauthorized,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 从 TokenService 获取 Token
    final accessToken = tokenService.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token 过期，尝试刷新
      final refreshToken = tokenService.getRefreshToken();

      if (refreshToken != null) {
        try {
          final response = await _refreshToken(refreshToken);
          if (response != null) {
            // 保存新 Token
            await tokenService.saveTokens(
              accessToken: response['access_token'] as String,
              refreshToken: response['refresh_token'] as String? ?? refreshToken,
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
          await tokenService.clearTokens();
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
        '${ApiConstants.apiPrefix}${ApiEndpoints.refreshToken}',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': ''}),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }
}

/// 日志拦截器
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      developer.log(
        '[API Request] ${options.method} ${options.uri}\n'
        'Headers: ${options.headers}'
        '${options.data != null ? '\nBody: ${options.data}' : ''}',
        name: 'api',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      developer.log(
        '[API Response] ${response.statusCode} ${response.requestOptions.uri}\n'
        'Data: ${response.data}',
        name: 'api',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConstants.isDebug) {
      developer.log(
        '[API Error] ${err.type} ${err.requestOptions.uri}\n'
        'Message: ${err.message}',
        name: 'api',
        error: err,
      );
    }
    handler.next(err);
  }
}