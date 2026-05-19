import 'package:equatable/equatable.dart';

/// 登录响应中的用户信息
class AuthUser extends Equatable {
  final int userIdent;
  final String mobilePhone;
  final String realName;
  final String? email;
  final int gender;
  final int? birthDay;
  final int coin;
  final int experience;
  final int grade;
  final int storeFrontID;
  final int joinTime;
  final int lastTime;
  final int status;
  final String? wxName;
  final String? wxAcatar;
  final Map<String, dynamic>? shoppingGuide;

  const AuthUser({
    required this.userIdent,
    required this.mobilePhone,
    required this.realName,
    this.email,
    this.gender = 0,
    this.birthDay,
    this.coin = 0,
    this.experience = 0,
    this.grade = 0,
    this.storeFrontID = 0,
    this.joinTime = 0,
    this.lastTime = 0,
    this.status = 1,
    this.wxName,
    this.wxAcatar,
    this.shoppingGuide,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userIdent: json['user_ident'] as int? ?? 0,
        mobilePhone: json['mobile_phone'] as String? ?? '',
        realName: json['real_name'] as String? ?? '',
        email: json['email'] as String?,
        gender: json['gender'] as int? ?? 0,
        birthDay: json['birth_day'] as int?,
        coin: json['coin'] as int? ?? 0,
        experience: json['experience'] as int? ?? 0,
        grade: json['grade'] as int? ?? 0,
        storeFrontID: json['store_front_id'] as int? ?? 0,
        joinTime: json['join_time'] as int? ?? 0,
        lastTime: json['last_time'] as int? ?? 0,
        status: json['status'] as int? ?? 1,
        wxName: json['wx_name'] as String?,
        wxAcatar: json['wx_avatar'] as String?,
        shoppingGuide: json['shopping_guide'] as Map<String, dynamic>?,
      );

  @override
  List<Object?> get props => [userIdent, mobilePhone, realName, status];
}

/// 登录请求
class LoginRequest {
  final String mobilePhone;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.mobilePhone,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
        'phone': mobilePhone,
        'pwd': password,
        'remember_me': rememberMe,
      };
}

/// 登录响应
class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final AuthUser? user;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn = 604800,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int? ?? 604800,
        user: json['user'] != null
            ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}

/// Token 模型
class TokenModel extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final DateTime createdAt;

  const TokenModel({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.createdAt,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int,
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
      };

  bool get isExpired {
    final expiryTime = createdAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }

  @override
  List<Object?> get props => [accessToken, expiresIn, createdAt];
}