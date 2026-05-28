// ============================================================
// 认证相关类型
// 从 z1-mid SDK auth-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

class EmployeeTokenPayload {
  final int id;
  final int user;
  final int exp;
  final int deptId;

  EmployeeTokenPayload({
    required this.id,
    required this.user,
    required this.exp,
    required this.deptId,
  });

  factory EmployeeTokenPayload.fromJson(Map<String, dynamic> json) {
    return EmployeeTokenPayload(
      id: json['id'] as int,
      user: json['user'] as int,
      exp: json['exp'] as int,
      deptId: json['deptId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'exp': exp,
      'deptId': deptId,
    };
  }
}

class Auth {
  final AuthID id;
  final String name;
  final String desc;
  final String? cate;

  Auth({
    required this.id,
    required this.name,
    required this.desc,
    this.cate,
  });

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      id: json['id'] as AuthID,
      name: json['name'] as String,
      desc: json['desc'] as String,
      cate: json['cate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'cate': cate,
    };
  }
}
