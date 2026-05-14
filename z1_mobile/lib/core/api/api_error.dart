import 'package:equatable/equatable.dart';

/// API 错误基类
class ApiException extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  List<Object?> get props => [message, statusCode, data];

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}

/// 服务器错误（500等）
class ServerException extends ApiException {
  const ServerException({super.message = '服务器错误'});
}

/// 网络错误（无连接等）
class NetworkException extends ApiException {
  const NetworkException({super.message = '网络连接失败'});
}

/// 认证错误（401等）
class AuthException extends ApiException {
  const AuthException({super.message = '认证失败'});
}

/// 解析错误（JSON解析失败等）
class ParseException extends ApiException {
  const ParseException({super.message = '数据解析失败'});
}

/// 超时错误
class TimeoutException extends ApiException {
  const TimeoutException({super.message = '请求超时'});
}

/// 未授权（Token过期等）
class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = '登录已过期，请重新登录'});
}

/// 业务错误（服务器返回的错误码）
class BusinessException extends ApiException {
  final String code;

  const BusinessException({
    required this.code,
    super.message = '业务错误',
    super.statusCode,
    super.data,
  });

  @override
  List<Object?> get props => [code, message, statusCode, data];
}