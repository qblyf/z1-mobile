import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int productID;
  final String productName;
  final int price;
  final String category;
  final String? code;

  const ProductModel({
    required this.productID,
    required this.productName,
    required this.price,
    required this.category,
    this.code,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productID: json['productID'] ?? json['id'] ?? 0,
      productName: json['productName'] ?? json['name'] ?? '',
      price: json['price'] ?? 0,
      category: json['category'] ?? '',
      code: json['code'],
    );
  }

  @override
  List<Object?> get props => [productID, productName, price, category];
}

class ProductListParams extends Equatable {
  final String? keyword;
  final String? category;
  final int page;
  final int pageSize;

  const ProductListParams({
    this.keyword,
    this.category,
    this.page = 1,
    this.pageSize = 50,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
      if (category != null && category!.isNotEmpty) 'category': category,
    };
  }

  @override
  List<Object?> get props => [keyword, category, page, pageSize];
}