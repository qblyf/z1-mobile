import 'package:equatable/equatable.dart';

class MemberModel extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? gender;
  final String? birthday;
  final int levelId;
  final String levelName;
  final int totalExperience;
  final int availableExperience;
  final double totalConsumption;
  final String? memberCardNo;
  final List<String> tags;
  final int createdAt;
  final int? lastVisitAt;
  final String status;

  const MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    this.gender,
    this.birthday,
    required this.levelId,
    required this.levelName,
    required this.totalExperience,
    required this.availableExperience,
    required this.totalConsumption,
    this.memberCardNo,
    this.tags = const [],
    required this.createdAt,
    this.lastVisitAt,
    required this.status,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['realName'] as String? ?? '';
    final phone = json['mobilePhone'] as String? ?? '';
    // 如果 realName 等于手机号，说明后端没有设置真实姓名，使用微信昵称
    final name = (rawName == phone && rawName.isNotEmpty)
        ? (json['wxName'] as String? ?? rawName)
        : rawName;
    return MemberModel(
      id: json['userIdent'] as int? ?? 0,
      name: name,
      phone: phone,
      gender: (json['gender'] as num?)?.toString(),
      birthday: json['birthday'] as String?,
      levelId: json['grade'] as int? ?? 0,
      levelName: _getLevelName(json['grade'] as int? ?? 0),
      totalExperience: json['experience'] as int? ?? 0,
      availableExperience: json['experience'] as int? ?? 0,
      totalConsumption: (json['totalConsumption'] as num?)?.toDouble() ?? 0.0,
      memberCardNo: json['memberCardNo'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] as int? ?? 0,
      lastVisitAt: json['lastVisitAt'] as int?,
      status: 'active',
    );
  }

  static String _getLevelName(int grade) {
    switch (grade) {
      case 1:
        return '普通会员';
      case 2:
        return '银卡会员';
      case 3:
        return '金卡会员';
      case 4:
        return '钻石会员';
      default:
        return '会员';
    }
  }

  String get maskedPhone {
    final str = phone.toString();
    if (str.length != 11) return str;
    return '${str.substring(0, 3)}****${str.substring(7)}';
  }

  double get availableExperienceYuan => availableExperience / 100;

  String get createdAtFormatted {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        levelId,
        levelName,
        totalExperience,
        availableExperience,
        status,
      ];
}