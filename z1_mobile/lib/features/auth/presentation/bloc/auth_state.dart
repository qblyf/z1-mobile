part of 'auth_bloc.dart';

/// 认证状态
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

/// 认证状态数据
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// 初始状态
  const AuthState.initial() : this(status: AuthStatus.initial);

  /// 加载中
  const AuthState.loading() : this(status: AuthStatus.loading);

  /// 已认证
  const AuthState.authenticated({User? user})
      : this(status: AuthStatus.authenticated, user: user);

  /// 未认证
  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  /// 失败
  const AuthState.failure({String? message})
      : this(status: AuthStatus.failure, errorMessage: message);

  /// 复制状态
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];

  @override
  String toString() => 'AuthState(status: $status, user: $user, error: $errorMessage)';
}