import 'package:equatable/equatable.dart';

class MemberModel extends Equatable {
  final int ident;
  final String realName;
  final String mobilePhone;
  final int experience;
  final String levelName; // 会员等级名称
  final double totalConsumption; // 历史消费金额（元）
  final int availableExperience; // 可用积分

  const MemberModel({
    required this.ident,
    required this.realName,
    required this.mobilePhone,
    this.experience = 0,
    this.levelName = '会员',
    this.totalConsumption = 0.0,
    this.availableExperience = 0,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final grade = json['grade'] as int? ?? 0;
    final rawName = json['realName'] as String? ?? '';
    final phone = json['mobilePhone'] as String? ?? '';
    // 如果 realName 等于手机号，说明后端没有设置真实姓名，使用微信昵称
    final realName = (rawName == phone && rawName.isNotEmpty) 
        ? (json['wxName'] as String? ?? rawName)
        : rawName;
    return MemberModel(
      ident: json['userIdent'] ?? json['ident'] ?? 0,
      realName: realName,
      mobilePhone: phone,
      experience: json['experience'] ?? 0,
      levelName: _getLevelName(grade),
      totalConsumption: (json['totalConsumption'] as num?)?.toDouble() ?? 0.0,
      availableExperience: json['experience'] ?? 0,
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

  @override
  List<Object?> get props => [ident, realName, mobilePhone, experience, levelName, totalConsumption];
}