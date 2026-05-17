import 'package:equatable/equatable.dart';

class MemberModel extends Equatable {
  final int ident;
  final String realName;
  final String mobilePhone;
  final int experience;

  const MemberModel({
    required this.ident,
    required this.realName,
    required this.mobilePhone,
    this.experience = 0,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      ident: json['ident'] ?? 0,
      realName: json['realName'] ?? json['name'] ?? '',
      mobilePhone: json['mobilePhone'] ?? json['phone'] ?? '',
      experience: json['experience'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [ident, realName, mobilePhone, experience];
}