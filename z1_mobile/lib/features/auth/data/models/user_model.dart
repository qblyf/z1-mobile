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

  /// 员工主部门 ID（来自 access token JWT payload，非 /members/self 返回）
  final int? deptID;

  /// 默认仓库 ID（主部门换算所得，登录后异步注入）
  final int? defaultWarehouseID;

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
    this.deptID,
    this.defaultWarehouseID,
  });

  /// 销售员标识 = 登录用户标识（开单 sellerIdent 直接用它，不冗余存储）
  int get sellerIdent => userIdent;

  // 注意：/members/self 实际返回 camelCase（userIdent/mobilePhone/...），
  // 兼容老的 snake_case 作为兜底。
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    T? pick<T>(String camel, String snake) =>
        (json[camel] ?? json[snake]) as T?;
    return AuthUser(
      userIdent: pick<int>('userIdent', 'user_ident') ?? 0,
      mobilePhone: pick<String>('mobilePhone', 'mobile_phone') ?? '',
      realName: pick<String>('realName', 'real_name') ?? '',
      email: pick<String>('email', 'email'),
      gender: pick<int>('gender', 'gender') ?? 0,
      birthDay: pick<int>('birthDay', 'birth_day'),
      coin: pick<int>('coin', 'coin') ?? 0,
      experience: pick<int>('experience', 'experience') ?? 0,
      grade: pick<int>('grade', 'grade') ?? 0,
      storeFrontID: pick<int>('storeFrontID', 'store_front_id') ?? 0,
      joinTime: pick<int>('joinTime', 'join_time') ?? 0,
      lastTime: pick<int>('lastTime', 'last_time') ?? 0,
      status: pick<int>('status', 'status') ?? 1,
      wxName: pick<String>('wxName', 'wx_name'),
      wxAcatar: pick<String>('wxAcatar', 'wx_avatar'),
      shoppingGuide:
          pick<Map<String, dynamic>>('shoppingGuide', 'shopping_guide'),
    );
  }

  AuthUser copyWith({
    int? deptID,
    int? defaultWarehouseID,
  }) {
    return AuthUser(
      userIdent: userIdent,
      mobilePhone: mobilePhone,
      realName: realName,
      email: email,
      gender: gender,
      birthDay: birthDay,
      coin: coin,
      experience: experience,
      grade: grade,
      storeFrontID: storeFrontID,
      joinTime: joinTime,
      lastTime: lastTime,
      status: status,
      wxName: wxName,
      wxAcatar: wxAcatar,
      shoppingGuide: shoppingGuide,
      deptID: deptID ?? this.deptID,
      defaultWarehouseID: defaultWarehouseID ?? this.defaultWarehouseID,
    );
  }

  @override
  List<Object?> get props =>
      [userIdent, mobilePhone, realName, status, deptID, defaultWarehouseID];
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
  final String? permissionToken;
  final int expiresIn;
  final AuthUser? user;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    this.permissionToken,
    this.expiresIn = 604800,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        permissionToken: json['permission_token'] as String?,
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
