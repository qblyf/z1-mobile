import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int productID;
  final String productName;
  final int price;
  final String category;
  final String? code;
  final String? genre;
  final String? categoryName;
  final String? barcode;
  final int? retailPrice;
  final int? memberPrice;
  final int? stock;
  final String? image;
  final String? unit;

  const ProductModel({
    required this.productID,
    required this.productName,
    required this.price,
    required this.category,
    this.code,
    this.genre,
    this.categoryName,
    this.barcode,
    this.retailPrice,
    this.memberPrice,
    this.stock,
    this.image,
    this.unit,
  });

  bool get isGoods => genre == 'goods';
  bool get isService => genre == 'service';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final retailPrice = json['retailPrice'] ?? json['price'];
    final memberPrice = json['memberPrice'];
    return ProductModel(
      productID: json['productID'] ?? json['id'] ?? 0,
      productName: json['productName'] ?? json['name'] ?? '',
      price: retailPrice is int ? retailPrice : (retailPrice as num?)?.toInt() ?? 0,
      category: json['category'] ?? json['categoryName'] ?? '',
      code: json['code'],
      genre: json['genre'],
      categoryName: json['categoryName'],
      barcode: json['barcode'],
      retailPrice: retailPrice is int ? retailPrice : (retailPrice as num?)?.toInt(),
      memberPrice: memberPrice is int ? memberPrice : (memberPrice as num?)?.toInt(),
      stock: json['stock'],
      image: json['image'],
      unit: json['unit'],
    );
  }

  ProductModel copyWith({
    int? productID,
    String? productName,
    int? price,
    String? category,
    String? code,
    String? genre,
    String? categoryName,
    String? barcode,
    int? retailPrice,
    int? memberPrice,
    int? stock,
    String? image,
    String? unit,
  }) {
    return ProductModel(
      productID: productID ?? this.productID,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      category: category ?? this.category,
      code: code ?? this.code,
      genre: genre ?? this.genre,
      categoryName: categoryName ?? this.categoryName,
      barcode: barcode ?? this.barcode,
      retailPrice: retailPrice ?? this.retailPrice,
      memberPrice: memberPrice ?? this.memberPrice,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props => [productID, productName, price, category, genre];
}

class CategoryModel extends Equatable {
  final int id;
  final String name;
  final int? parentId;
  final int? sort;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.sort,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parentId: json['parentId'] ?? json['parent_id'],
      sort: json['sort'],
    );
  }

  @override
  List<Object?> get props => [id, name, parentId, sort];
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

class ProductPriceModel extends Equatable {
  final int productId;
  final int price;
  final String? unit;

  const ProductPriceModel({
    required this.productId,
    required this.price,
    this.unit,
  });

  factory ProductPriceModel.fromJson(Map<String, dynamic> json) {
    return ProductPriceModel(
      productId: json['productId'] ?? json['id'] ?? 0,
      price: json['price'] ?? 0,
      unit: json['unit'],
    );
  }

  @override
  List<Object?> get props => [productId, price, unit];
}