import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final int id;
  final String name;
  final String? shortName;
  final int price;
  final int? categoryId;
  final String? categoryName;
  final bool isGoods;

  const ServiceModel({
    required this.id,
    required this.name,
    this.shortName,
    required this.price,
    this.categoryId,
    this.categoryName,
    this.isGoods = false,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['shortName'],
      price: json['price'] is int ? json['price'] : (json['price'] as num?)?.toInt() ?? 0,
      categoryId: json['categoryId'] ?? json['category_id'],
      categoryName: json['categoryName'],
      isGoods: json['isGoods'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, shortName, price, categoryId, categoryName, isGoods];
}

class ServiceCategoryModel extends Equatable {
  final int id;
  final String name;
  final int? parentId;
  final int? sort;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.sort,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parentId: json['parentId'] ?? json['parent_id'],
      sort: json['sort'],
    );
  }

  @override
  List<Object?> get props => [id, name, parentId, sort];
}