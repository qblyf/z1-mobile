import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import 'api_error.dart';
import 'api_interceptor.dart';

/// API 客户端封装
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      TokenInterceptor(
        dio: _dio,
        secureStorage: _secureStorage,
        onUnauthorized: _onUnauthorized,
      ),
      LoggingInterceptor(),
    ]);
  }

  Future<void> _onUnauthorized() async {
    // 清除本地 Token
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  /// GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        '${ApiConstants.apiPrefix}$path',
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        '${ApiConstants.apiPrefix}$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        '${ApiConstants.apiPrefix}$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        '${ApiConstants.apiPrefix}$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH 请求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        '${ApiConstants.apiPrefix}$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 统一错误处理
  ApiException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedException();
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message: e.response?.statusMessage ?? '服务器错误');
        } else if (statusCode != null && statusCode >= 400) {
          // 业务错误
          final data = e.response?.data;
          if (data is Map && data.containsKey('code')) {
            return BusinessException(
              code: data['code'].toString(),
              message: data['message'] ?? '请求失败',
              statusCode: statusCode,
              data: data,
            );
          }
          return ApiException(
            message: data?['message'] ?? '请求失败',
            statusCode: statusCode,
            data: data,
          );
        }
        return const ServerException();
      case DioExceptionType.cancel:
        return const ApiException(message: '请求已取消');
      case DioExceptionType.badCertificate:
        return const ApiException(message: '证书错误');
      case DioExceptionType.unknown:
      default:
        if (e.message?.contains('SocketException') ?? false) {
          return const NetworkException();
        }
        return ApiException(message: e.message ?? '未知错误');
    }
  }

  /// 保存 Token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
    if (expiresIn != null) {
      final expiryTime = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();
      await _secureStorage.write(key: AppConstants.tokenExpiryKey, value: expiryTime);
    }
  }

  /// 清除 Token
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: AppConstants.tokenExpiryKey);
  }

  /// 检查是否已登录
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}