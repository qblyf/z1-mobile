import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int productID;
  final String productName;
  final int price;
  final String category;
  final int? categoryId;
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
    this.categoryId,
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
      categoryId: json['categoryId'] ?? json['categoryId'] ?? json['category_id'],
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
    int? categoryId,
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
      categoryId: categoryId ?? this.categoryId,
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
  final int? pid; // 上级分类 ID（0=顶级）
  final List<int>? chain; // 分类链
  final int? state; // 分类状态

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.sort,
    this.pid,
    this.chain,
    this.state,
  });

  /// 是否为叶子节点（无子分类）
  bool get isLeaf => true; // 需要在树构建时根据是否有子节点判断

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parentId: json['parentId'] ?? json['parent_id'] ?? json['pid'],
      sort: json['sort'] ?? json['order'],
      pid: json['pid'],
      chain: (json['chain'] as List<dynamic>?)?.map((e) => e as int).toList(),
      state: json['state'],
    );
  }

  @override
  List<Object?> get props => [id, name, parentId, sort, pid, chain, state];
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

class SkuModel extends Equatable {
  final int skuId;
  final String skuName;
  final int price;
  final int? retailPrice;
  final int? memberPrice;
  final int? stock;
  final String? unit;
  final String? image;
  final Map<String, dynamic>? specs;

  const SkuModel({
    required this.skuId,
    required this.skuName,
    required this.price,
    this.retailPrice,
    this.memberPrice,
    this.stock,
    this.unit,
    this.image,
    this.specs,
  });

  factory SkuModel.fromJson(Map<String, dynamic> json) {
    return SkuModel(
      skuId: json['skuId'] ?? json['id'] ?? 0,
      skuName: json['skuName'] ?? json['name'] ?? '',
      price: json['price'] is int ? json['price'] : ((json['price'] as num?)?.toInt() ?? 0),
      retailPrice: json['retailPrice'] is int ? json['retailPrice'] : ((json['retailPrice'] as num?)?.toInt()),
      memberPrice: json['memberPrice'] is int ? json['memberPrice'] : ((json['memberPrice'] as num?)?.toInt()),
      stock: json['stock'],
      unit: json['unit'],
      image: json['image'],
      specs: json['specs'] as Map<String, dynamic>?,
    );
  }

  /// 从 ProductModel 转换
  factory SkuModel.fromProduct(ProductModel product) {
    return SkuModel(
      skuId: product.productID,
      skuName: product.productName,
      price: product.price,
      retailPrice: product.retailPrice,
      memberPrice: product.memberPrice,
      stock: product.stock,
      unit: product.unit,
      image: product.image,
    );
  }

  @override
  List<Object?> get props => [skuId, skuName, price];
}

class SpuModel extends Equatable {
  final int spuId;
  final String spuName;
  final int? retailPrice;
  final int? memberPrice;
  final int? stock;
  final String? image;
  final String? categoryName;
  final List<SkuModel> skus;

  const SpuModel({
    required this.spuId,
    required this.spuName,
    this.retailPrice,
    this.memberPrice,
    this.stock,
    this.image,
    this.categoryName,
    this.skus = const [],
  });

  factory SpuModel.fromJson(Map<String, dynamic> json) {
    final skuList = json['skuList'] as List<dynamic>? ?? [];
    return SpuModel(
      spuId: json['spuId'] ?? json['id'] ?? 0,
      spuName: json['spuName'] ?? json['name'] ?? '',
      retailPrice: json['retailPrice'] is int ? json['retailPrice'] : ((json['retailPrice'] as num?)?.toInt()),
      memberPrice: json['memberPrice'] is int ? json['memberPrice'] : ((json['memberPrice'] as num?)?.toInt()),
      stock: json['stock'],
      image: json['image'],
      categoryName: json['categoryName'],
      skus: skuList.map((s) => SkuModel.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }

  @override
  List<Object?> get props => [spuId, spuName, skus];
}

class CategoryWithSpu extends Equatable {
  final int id;
  final String name;
  final int? parentId;
  final List<SpuModel> spus;

  const CategoryWithSpu({
    required this.id,
    required this.name,
    this.parentId,
    this.spus = const [],
  });

  factory CategoryWithSpu.fromJson(Map<String, dynamic> json) {
    final spuList = json['spuList'] as List<dynamic>? ?? [];
    return CategoryWithSpu(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parentId: json['parentId'],
      spus: spuList.map((s) => SpuModel.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, spus];
}

/// 分类树节点（支持层级结构）
class CategoryTreeNode extends Equatable {
  final int id;
  final String name;
  final int pid; // 父分类 ID，0 表示顶级
  final List<CategoryTreeNode> children;
  final List<SpuModel> spus; // 只在叶子节点关联 SPU

  const CategoryTreeNode({
    required this.id,
    required this.name,
    this.pid = 0,
    this.children = const [],
    this.spus = const [],
  });

  /// 是否为叶子节点
  bool get isLeaf => children.isEmpty && spus.isNotEmpty;

  /// 是否为顶级节点
  bool get isTopLevel => pid == 0;

  CategoryTreeNode copyWith({
    int? id,
    String? name,
    int? pid,
    List<CategoryTreeNode>? children,
    List<SpuModel>? spus,
  }) {
    return CategoryTreeNode(
      id: id ?? this.id,
      name: name ?? this.name,
      pid: pid ?? this.pid,
      children: children ?? this.children,
      spus: spus ?? this.spus,
    );
  }

  @override
  List<Object?> get props => [id, name, pid, children, spus];
}