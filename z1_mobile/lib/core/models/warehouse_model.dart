import 'package:equatable/equatable.dart';

/// 仓库（共享展示模型，供零售/库存等模块复用）。
///
/// 注：inventory 模块历史上各自定义了同形状的 WarehouseModel，
/// 后续可统一迁移到此处；本期零售开单优先复用本模型。
class WarehouseModel extends Equatable {
  final int id;
  final String name;
  final String? number;

  const WarehouseModel({
    required this.id,
    required this.name,
    this.number,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      number: json['number'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
