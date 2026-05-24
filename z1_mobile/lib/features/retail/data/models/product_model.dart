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
  final int? hasSerial; // 是否有序列号：1=无序列号，2=有序列号

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
    this.hasSerial,
  });

  bool get isGoods => genre == 'goods';
  bool get isService => genre == 'service';
  bool get requiresSerial => hasSerial == 2; // hasSerial=2 表示需要序列号

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
      hasSerial: json['hasSerial'],
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
  final String? spell; // 拼音码
  final int? parentId;
  final int? sort;
  final int? pid; // 上级分类 ID（0=顶级）
  final List<int>? chain; // 分类链
  final int? state; // 分类状态

  const CategoryModel({
    required this.id,
    required this.name,
    this.spell,
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
      spell: json['spell'] as String?,
      parentId: json['parentId'] ?? json['parent_id'] ?? json['pid'],
      sort: json['sort'] ?? json['order'],
      pid: json['pid'],
      chain: (json['chain'] as List<dynamic>?)?.map((e) => e as int).toList(),
      state: json['state'],
    );
  }

  @override
  List<Object?> get props => [id, name, spell, parentId, sort, pid, chain, state];
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
  final int spuId;
  final String skuName;
  final int price;
  final int? retailPrice;
  final int? memberPrice;
  final int? stock;
  final String? unit;
  final String? image;
  final int? hasSerial;
  final Map<String, dynamic>? specs;

  const SkuModel({
    required this.skuId,
    this.spuId = 0,
    required this.skuName,
    required this.price,
    this.retailPrice,
    this.memberPrice,
    this.stock,
    this.unit,
    this.image,
    this.hasSerial,
    this.specs,
  });

  factory SkuModel.fromJson(Map<String, dynamic> json) {
    return SkuModel(
      skuId: json['skuId'] ?? json['skuID'] ?? json['id'] ?? 0,
      spuId: json['spuId'] ?? json['spuID'] ?? 0,
      skuName: json['skuName'] ?? json['name'] ?? '',
      price: json['price'] is int ? json['price'] : ((json['price'] as num?)?.toInt() ?? 0),
      retailPrice: json['retailPrice'] is int ? json['retailPrice'] : ((json['retailPrice'] as num?)?.toInt()),
      memberPrice: json['memberPrice'] is int ? json['memberPrice'] : ((json['memberPrice'] as num?)?.toInt()),
      stock: json['stock'],
      unit: json['unit'],
      image: json['image'],
      hasSerial: json['hasSerial'] is int ? json['hasSerial'] : (json['hasSerial'] as num?)?.toInt(),
      specs: json['specs'] as Map<String, dynamic>?,
    );
  }

  /// 从 ProductModel 转换
  factory SkuModel.fromProduct(ProductModel product) {
    return SkuModel(
      skuId: product.productID,
      spuId: 0,
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
  List<Object?> get props => [skuId, spuId, skuName, price, hasSerial];
}

class SpuModel extends Equatable {
  final int spuId;
  final String spuName;
  final String? brand; // 品牌
  final String? series; // 系列
  final String? generation; // 代际
  final int? minPrice; // 最低价格（分）
  final int? maxPrice; // 最高价格（分）
  final int? retailPrice;
  final int? memberPrice;
  final String? image;
  final String? categoryName;
  final List<SkuModel> skus;
  final int? hasSerial; // 是否有序列号：1=无序列号，2=有序列号
  final int? saleStock; // 可售库存数量（通过 /spu/get-stock 单独获取）
  // 注意：SPU 本身不含库存字段，库存需通过 /spu/get-stock 接口单独查询

  const SpuModel({
    required this.spuId,
    required this.spuName,
    this.brand,
    this.series,
    this.generation,
    this.minPrice,
    this.maxPrice,
    this.retailPrice,
    this.memberPrice,
    this.image,
    this.categoryName,
    this.skus = const [],
    this.hasSerial,
    this.saleStock,
  });

  /// 是否需要序列号
  bool get requiresSerial => hasSerial == 2;

  /// 获取显示价格（优先用 minPrice-maxPrice 范围价）
  String get priceDisplay {
    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) {
        return '¥${(minPrice! / 100).toStringAsFixed(2)}';
      }
      return '¥${(minPrice! / 100).toStringAsFixed(2)}-${(maxPrice! / 100).toStringAsFixed(2)}';
    }
    if (retailPrice != null) {
      return '¥${(retailPrice! / 100).toStringAsFixed(2)}';
    }
    return '暂无价格';
  }

  /// 解析图片字段，支持多种格式
  static String? _parseImage(Map<String, dynamic> json) {
    // 1. 直接的 image 字段
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      return json['image'].toString();
    }
    
    // 2. mainImage 字段
    if (json['mainImage'] != null && json['mainImage'].toString().isNotEmpty) {
      return json['mainImage'].toString();
    }
    
    // 3. mainImages 数组
    final mainImages = json['mainImages'];
    if (mainImages is List && mainImages.isNotEmpty) {
      return mainImages.first.toString();
    }
    
    // 4. images.thumbnail (嵌套结构)
    final images = json['images'];
    if (images is Map<String, dynamic>) {
      if (images['thumbnail'] != null && images['thumbnail'].toString().isNotEmpty) {
        return images['thumbnail'].toString();
      }
      final nestedMainImages = images['mainImages'];
      if (nestedMainImages is List && nestedMainImages.isNotEmpty) {
        return nestedMainImages.first.toString();
      }
    }
    
    // 5. imgUrl 字段
    if (json['imgUrl'] != null && json['imgUrl'].toString().isNotEmpty) {
      return json['imgUrl'].toString();
    }
    
    return null;
  }

  factory SpuModel.fromJson(Map<String, dynamic> json) {
    final skuList = json['skuList'] as List<dynamic>? ?? [];
    
    // 尝试多种可能的字段名获取价格
    int? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String && value.isNotEmpty) {
        return int.tryParse(value);
      }
      return null;
    }
    
    final minPrice = parsePrice(json['minPrice'] ?? json['min_price'] ?? json['minPriceYuan']);
    final maxPrice = parsePrice(json['maxPrice'] ?? json['max_price'] ?? json['maxPriceYuan']);
    final retailPrice = parsePrice(json['retailPrice'] ?? json['retail_price'] ?? json['price'] ?? json['salePrice']);
    final memberPrice = parsePrice(json['memberPrice'] ?? json['member_price']);
    
    return SpuModel(
      spuId: json['spuId'] ?? json['id'] ?? 0,
      spuName: json['spuName'] ?? json['name'] ?? '',
      brand: json['brand'] as String?,
      series: json['series'] as String?,
      generation: json['generation'] as String?,
      minPrice: minPrice,
      maxPrice: maxPrice,
      retailPrice: retailPrice,
      memberPrice: memberPrice,
      image: _parseImage(json),
      categoryName: json['categoryName'],
      skus: skuList.map((s) => SkuModel.fromJson(s as Map<String, dynamic>)).toList(),
      hasSerial: json['hasSerial'],
      saleStock: json['saleStock'] ?? json['stock'],
    );
  }

  SpuModel copyWith({
    int? spuId,
    String? spuName,
    String? brand,
    String? series,
    String? generation,
    int? minPrice,
    int? maxPrice,
    int? retailPrice,
    int? memberPrice,
    String? image,
    String? categoryName,
    List<SkuModel>? skus,
    int? hasSerial,
    int? saleStock,
  }) {
    return SpuModel(
      spuId: spuId ?? this.spuId,
      spuName: spuName ?? this.spuName,
      brand: brand ?? this.brand,
      series: series ?? this.series,
      generation: generation ?? this.generation,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      retailPrice: retailPrice ?? this.retailPrice,
      memberPrice: memberPrice ?? this.memberPrice,
      image: image ?? this.image,
      categoryName: categoryName ?? this.categoryName,
      skus: skus ?? this.skus,
      hasSerial: hasSerial ?? this.hasSerial,
      saleStock: saleStock ?? this.saleStock,
    );
  }

  @override
  List<Object?> get props => [spuId, spuName, brand, series, minPrice, maxPrice, skus, saleStock];
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

/// 商城分类模型（3级结构：品类 -> 品牌 -> 系列）
/// API: /mall-category/list
class MallCategoryModel extends Equatable {
  final int id;
  final String title; // 名称
  final int level; // 层级：1=品类，2=品牌，3=系列
  final List<int> pids; // 父级分类ID列表
  final int weight; // 权重
  final String? spell; // 拼音码（仅3级有）
  final String? imgUrl; // 分类图片（仅3级有）

  const MallCategoryModel({
    required this.id,
    required this.title,
    required this.level,
    this.pids = const [],
    this.weight = 0,
    this.spell,
    this.imgUrl,
  });

  /// 是否为品类（1级）
  bool get isCategory => level == 1;

  /// 是否为品牌（2级）
  bool get isBrand => level == 2;

  /// 是否为系列（3级/叶子节点）
  bool get isSeries => level == 3;

  /// 是否为叶子节点（系列）
  bool get isLeaf => level == 3;

  /// 父品类ID（level=2时有）
  int? get categoryId => pids.isNotEmpty ? pids[0] : null;

  /// 父品牌ID（level=3时有）
  int? get brandId => pids.length > 1 ? pids[1] : null;

  factory MallCategoryModel.fromJson(Map<String, dynamic> json) {
    return MallCategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      level: json['level'] ?? 1,
      pids: (json['pids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      weight: json['weight'] ?? 0,
      spell: json['spell'] as String?,
      imgUrl: json['imgUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, level, pids, weight, spell, imgUrl];
}

/// 商城分类树节点
class MallCategoryTreeNode extends Equatable {
  final int id;
  final String title;
  final int level;
  final List<int> pids;
  final List<MallCategoryTreeNode> children;
  final List<SpuModel> spus;

  const MallCategoryTreeNode({
    required this.id,
    required this.title,
    required this.level,
    this.pids = const [],
    this.children = const [],
    this.spus = const [],
  });

  bool get isLeaf => level == 3 && spus.isNotEmpty;

  MallCategoryTreeNode copyWith({
    int? id,
    String? title,
    int? level,
    List<int>? pids,
    List<MallCategoryTreeNode>? children,
    List<SpuModel>? spus,
  }) {
    return MallCategoryTreeNode(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      pids: pids ?? this.pids,
      children: children ?? this.children,
      spus: spus ?? this.spus,
    );
  }

  @override
  List<Object?> get props => [id, title, level, pids, children, spus];
}