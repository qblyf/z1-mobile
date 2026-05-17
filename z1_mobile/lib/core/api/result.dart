import 'package:equatable/equatable.dart';

/// API 错误类型
enum ApiErrorType {
  serverError,
  networkError,
  unauthorized,
  validationError,
  unknown,
}

/// API 错误
class ApiFailure extends Equatable {
  final ApiErrorType type;
  final String message;
  final int? statusCode;

  const ApiFailure({
    required this.type,
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [type, message, statusCode];

  factory ApiFailure.serverError([String? message]) => ApiFailure(
        type: ApiErrorType.serverError,
        message: message ?? '服务器错误',
      );

  factory ApiFailure.networkError([String? message]) => ApiFailure(
        type: ApiErrorType.networkError,
        message: message ?? '网络错误',
      );

  factory ApiFailure.unauthorized([String? message]) => ApiFailure(
        type: ApiErrorType.unauthorized,
        message: message ?? '未授权',
      );

  factory ApiFailure.validationError([String? message]) => ApiFailure(
        type: ApiErrorType.validationError,
        message: message ?? '参数错误',
      );

  factory ApiFailure.unknown([String? message]) => ApiFailure(
        type: ApiErrorType.unknown,
        message: message ?? '未知错误',
      );
}

/// 结果类型 Either
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get value => switch (this) {
        Success(value: final v) => v,
        Failure() => null,
      };

  ApiFailure? get failure => switch (this) {
        Success() => null,
        Failure(failure: final f) => f,
      };

  R fold<R>(R Function(ApiFailure failure) onFailure, R Function(T value) onSuccess) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(failure: final f) => onFailure(f),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Success(transform(v)),
      Failure(failure: final f) => Failure(f),
    };
  }
}

/// 成功结果
class Success<T> extends Result<T> {
  @override
  final T value;

  const Success(this.value);
}

/// 失败结果
class Failure<T> extends Result<T> {
  @override
  final ApiFailure failure;

  const Failure(this.failure);
}