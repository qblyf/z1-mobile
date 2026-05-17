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

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        gender: json['gender'] as String?,
        birthday: json['birthday'] as String?,
        levelId: json['levelId'] as int? ?? 0,
        levelName: json['levelName'] as String? ?? '',
        totalExperience: json['totalExperience'] as int? ?? 0,
        availableExperience: json['availableExperience'] as int? ?? 0,
        totalConsumption: (json['totalConsumption'] as num?)?.toDouble() ?? 0.0,
        memberCardNo: json['memberCardNo'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: json['createdAt'] as int? ?? 0,
        lastVisitAt: json['lastVisitAt'] as int?,
        status: json['status'] as String? ?? 'active',
      );

  String get maskedPhone {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
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