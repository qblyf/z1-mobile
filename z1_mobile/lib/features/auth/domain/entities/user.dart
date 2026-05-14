import 'package:equatable/equatable.dart';

/// 用户实体
class User extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? avatar;
  final String? shopId;
  final String? shopName;
  final List<String> roles;

  const User({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.avatar,
    this.shopId,
    this.shopName,
    this.roles = const [],
  });

  @override
  List<Object?> get props => [id, name, phone, email, avatar, shopId, shopName, roles];
}

/// 登录请求
class LoginRequest extends Equatable {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

/// 登录响应
class LoginResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  @override
  List<Object> get props => [accessToken, refreshToken, expiresIn, user];
}