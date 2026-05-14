part of 'auth_bloc.dart';

/// 认证事件
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 检查认证状态
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// 登录
class AuthLoginRequested extends AuthEvent {
  final String account;
  final String password;

  const AuthLoginRequested({
    required this.account,
    required this.password,
  });

  @override
  List<Object?> get props => [account, password];
}

/// 登出
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// 清除认证状态
class AuthCleared extends AuthEvent {
  const AuthCleared();
}