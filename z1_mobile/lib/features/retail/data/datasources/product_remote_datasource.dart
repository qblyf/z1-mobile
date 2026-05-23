import 'package:equatable/equatable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/product_model.dart';

/// SPU 临时数据结构（用于分类下 SPU 分组）
class _SpuData {
  final String spuName;
  final List<SkuModel> skus;

  _SpuData({required this.spuName, required this.skus});
}

class ProductSelectBaseResult {
  final List<ProductModel> products;
  final List<CategoryModel> categories;

  const ProductSelectBaseResult({
    required this.products,
    required this.categories,
  });
}

class SkuSelectBaseResult {
  final List<CategoryWithSpu> categories;

  const SkuSelectBaseResult({required this.categories});

  /// 从JSON数据构造 [SkuSelectBaseResult]
  ///
  /// 健壮可扩展设计：
  /// - 支持多种API返回格式：categoryList、res.spuList、扁平SKU数组
  /// - 空数据安全处理：返回空数组而非抛出异常
  /// - 类型安全：动态类型严格检查，异常时返回空结果
  factory SkuSelectBaseResult.fromJson(Map<String, dynamic> data) {
    // 策略1：检查标准 categoryList 格式
    final categoryList = data['categoryList'] as List<dynamic>?;
    if (categoryList != null && categoryList.isNotEmpty) {
      try {
        return SkuSelectBaseResult(
          categories: categoryList
              .map((json) => CategoryWithSpu.fromJson(json as Map<String, dynamic>))
              .toList(),
        );
      } catch (e) {
        // categoryList 解析失败，尝试其他策略
      }
    }

    // 策略2：检查 res 数组格式
    // 处理多种可能的 res 结构：可能是 List<CategoryWithSpu> 或 List<SkuModel>
    final resList = data['res'] as List<dynamic>?;
    if (resList == null || resList.isEmpty) {
      return const SkuSelectBaseResult(categories: []);
    }

    try {
      // 尝试将 resList 第一项作为分类结构解析
      final firstItem = resList.first as Map<String, dynamic>?;
      if (firstItem != null && firstItem.containsKey('spuList')) {
        // 策略2a: res 是分类列表结构 (List<CategoryWithSpu>)
        return SkuSelectBaseResult(
          categories: resList
              .map((json) => CategoryWithSpu.fromJson(json as Map<String, dynamic>))
              .toList(),
        );
      }
    } catch (e) {
      // 第一项结构不匹配，继续尝试扁平SKU解析
    }

    // 策略3：扁平SKU结构 (API /sku/select-base 返回的扁平数组)
    // 将所有 res 元素作为 SkuModel 解析，包装成"全部商品"分类
    try {
      final flatSkus = <SkuModel>[];
      for (final item in resList) {
        if (item is Map<String, dynamic>) {
          flatSkus.add(SkuModel.fromJson(item));
        }
      }

      if (flatSkus.isNotEmpty) {
        return SkuSelectBaseResult(
          categories: [
            CategoryWithSpu(id: 0, name: '全部商品', spus: [
              SpuModel(
                spuId: 0,
                spuName: '全部商品',
                skus: flatSkus,
              ),
            ]),
          ],
        );
      }
    } catch (e) {
      // 扁平SKU解析失败
    }

    // 所有策略均失败，返回空结果（不抛异常，保持运行）
    return const SkuSelectBaseResult(categories: []);
  }
}

class ServeListResult {
  final List<ServeModel> serves;
  final List<CategoryModel> categories;

  const ServeListResult({required this.serves, required this.categories});

  factory ServeListResult.fromJson(Map<String, dynamic> data) {
    final categoryList = data['categoryList'] as List<dynamic>? ?? [];
    final serveList = data['serveList'] as List<dynamic>? ?? [];
    return ServeListResult(
      categories: categoryList.map((c) => CategoryModel.fromJson(c as Map<String, dynamic>)).toList(),
      serves: serveList.map((s) => ServeModel.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}

class ServeModel extends Equatable {
  final int id;
  final String name;
  final String? shortName;
  final int price;
  final int? retailPrice;
  final int? memberPrice;
  final String? categoryName;
  final bool isGoods;

  const ServeModel({
    required this.id,
    required this.name,
    this.shortName,
    required this.price,
    this.retailPrice,
    this.memberPrice,
    this.categoryName,
    this.isGoods = false,
  });

  factory ServeModel.fromJson(Map<String, dynamic> json) {
    return ServeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['shortName'],
      price: json['price'] is int ? json['price'] : ((json['price'] as num?)?.toInt() ?? 0),
      retailPrice: json['retailPrice'] is int ? json['retailPrice'] : ((json['retailPrice'] as num?)?.toInt()),
      memberPrice: json['memberPrice'] is int ? json['memberPrice'] : ((json['memberPrice'] as num?)?.toInt()),
      categoryName: json['categoryName'],
      isGoods: json['isGoods'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, price];
}

abstract class ProductRemoteDataSource {
  Future<Result<List<ProductModel>>> getProductList(ProductListParams params);
  Future<Result<List<ProductModel>>> searchProducts(String keyword);
  Future<Result<List<ProductPriceModel>>> getProductPriceList(List<int> productIds);
  Future<Result<ProductSelectBaseResult>> getProductSelectBase();
  Future<Result<SkuSelectBaseResult>> getSkuSelectBase();
  Future<Result<ServeListResult>> getServeList();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<ProductModel>>> getProductList(ProductListParams params) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.productList,
      queryParameters: params.toQueryParams(),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<List<ProductModel>>> searchProducts(String keyword) async {
    final params = ProductListParams(keyword: keyword);
    return getProductList(params);
  }

  @override
  Future<Result<List<ProductPriceModel>>> getProductPriceList(List<int> productIds) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.productPriceList,
      data: {'productIds': productIds},
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => ProductPriceModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<ProductSelectBaseResult>> getProductSelectBase() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.productSelectBase,
      parser: (data) => data,
    );

    return response.map((data) {
      final categoryList = data['categoryList'] as List<dynamic>? ?? [];
      final productList = data['productList'] as List<dynamic>? ?? [];

      final categories = categoryList
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final products = productList
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return ProductSelectBaseResult(
        products: products,
        categories: categories,
      );
    });
  }

  @override
  Future<Result<SkuSelectBaseResult>> getSkuSelectBase() async {
    // 1. 先获取分类列表
    final categoryResponse = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.categoryList(type: 1),
      parser: (data) => data,
    );

    // 2. 获取 SKU 列表
    final skuResponse = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.productSelectBase,
      parser: (data) => data,
    );

    // 如果任一请求失败，返回错误
    if (categoryResponse.isFailure) {
      return Failure(categoryResponse.failure!);
    }
    if (skuResponse.isFailure) {
      return Failure(skuResponse.failure!);
    }

    final categoryData = categoryResponse.value!;
    final skuData = skuResponse.value!;

    // 解析分类列表
    final categoryList = categoryData['list'] as List<dynamic>? ?? [];
    final categories = categoryList
        .whereType<Map<String, dynamic>>()
        .map((json) => CategoryModel.fromJson(json))
        .toList();

    // 构建分类树和节点映射
    final categoryTreeResult = _buildCategoryTree(categories);
    final categoryTree = categoryTreeResult.$1;
    final nodeMap = categoryTreeResult.$2;

    // 解析 SKU 数据，按 (spuCateId, spuId) 分组
    final resList = skuData['res'] as List<dynamic>? ?? [];

    // 数据结构: Map<spuCateId, Map<spuId, { spuName, skus }>>
    final spuByCategory = <int, Map<int, _SpuData>>{};
    // 同时收集所有 SKU 用于"全部商品"
    final allSkus = <SkuModel>[];

    for (final item in resList) {
      if (item is! Map<String, dynamic>) continue;

      // 过滤非活跃商品 (state: 1 = 活跃)
      final state = item['state'] as int? ?? 0;
      if (state != 1) continue;

      final skuId = item['skuID'] as int? ?? 0;
      final spuId = item['spuID'] as int? ?? 0;
      final spuName = item['spuName'] as String? ?? '未知商品';
      final spuCateId = item['spuCateID'] as int? ?? 0;

      if (spuId == 0 || spuCateId == 0) continue;

      // 解析 SKU 信息
      final sku = SkuModel(
        skuId: skuId,
        skuName: item['skuName'] as String? ?? '',
        price: 0,
        retailPrice: 0,
        memberPrice: 0,
        stock: 0,
        unit: item['unit'] as String?,
        image: null,
        specs: null,
      );

      allSkus.add(sku);

      // 按分类分组 SPU
      spuByCategory.putIfAbsent(spuCateId, () => {});
      final spuMap = spuByCategory[spuCateId]!;
      spuMap.putIfAbsent(spuId, () => _SpuData(spuName: spuName, skus: []));
      spuMap[spuId]!.skus.add(sku);
    }

    // 将 SPU 关联到叶子分类节点
    for (final entry in spuByCategory.entries) {
      final cateId = entry.key;
      final spuMap = entry.value;

      final node = nodeMap[cateId];
      if (node != null) {
        // 构建 SPU 列表
        final spus = spuMap.entries.map((e) => SpuModel(
          spuId: e.key,
          spuName: e.value.spuName,
          skus: e.value.skus,
        )).toList();

        // 更新节点
        final index = categoryTree.indexWhere((n) => n.id == cateId);
        if (index >= 0) {
          categoryTree[index] = node.copyWith(spus: spus);
        }
        nodeMap[cateId] = node.copyWith(spus: spus);
      }
    }

    // 扁平化为 CategoryWithSpu 列表（只显示有商品的叶子分类）
    final flatCategories = _flattenCategoryTree(categoryTree);

    // 添加"全部商品"分类
    if (allSkus.isNotEmpty) {
      flatCategories.insert(
        0,
        CategoryWithSpu(
          id: 0,
          name: '全部商品',
          spus: [
            SpuModel(
              spuId: 0,
              spuName: '全部商品',
              skus: allSkus,
            ),
          ],
        ),
      );
    }

    return Success(SkuSelectBaseResult(categories: flatCategories));
  }

  /// 构建分类树，返回 (树列表, 节点映射)
  (List<CategoryTreeNode>, Map<int, CategoryTreeNode>) _buildCategoryTree(
    List<CategoryModel> categories,
  ) {
    final nodeMap = <int, CategoryTreeNode>{};
    final topLevelNodes = <CategoryTreeNode>[];

    // 创建所有节点
    for (final cat in categories) {
      nodeMap[cat.id] = CategoryTreeNode(
        id: cat.id,
        name: cat.name,
        pid: cat.pid ?? 0,
      );
    }

    // 构建树
    for (final cat in categories) {
      final node = nodeMap[cat.id]!;
      if (cat.pid == 0 || cat.pid == null) {
        topLevelNodes.add(node);
      } else {
        final parent = nodeMap[cat.pid];
        if (parent != null) {
          final children = List<CategoryTreeNode>.from(parent.children);
          children.add(node);
          nodeMap[parent.id] = parent.copyWith(children: children);
        } else {
          topLevelNodes.add(node);
        }
      }
    }

    return (topLevelNodes, nodeMap);
  }

  /// 扁平化分类树为列表（只显示有商品的分类）
  List<CategoryWithSpu> _flattenCategoryTree(List<CategoryTreeNode> nodes) {
    final result = <CategoryWithSpu>[];

    for (final node in nodes) {
      if (node.children.isEmpty) {
        // 叶子节点，如果有 SPU 则添加
        if (node.spus.isNotEmpty) {
          result.add(CategoryWithSpu(
            id: node.id,
            name: node.name,
            spus: node.spus,
          ));
        }
      } else {
        // 非叶子节点，递归处理子节点（只添加有商品的叶子）
        final childCategories = _flattenCategoryTree(node.children);
        result.addAll(childCategories);
      }
    }

    return result;
  }

  @override
  Future<Result<ServeListResult>> getServeList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.serveList,
      parser: (data) => data,
    );

    return response.map((data) => ServeListResult.fromJson(data));
  }
}