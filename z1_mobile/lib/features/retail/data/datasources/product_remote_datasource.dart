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

/// SPU 库存信息
class SpuStockInfo {
  final int spuId;
  final int stock;
  final int lockStock;
  final int saleStock;

  const SpuStockInfo({
    required this.spuId,
    required this.stock,
    required this.lockStock,
    required this.saleStock,
  });

  factory SpuStockInfo.fromJson(Map<String, dynamic> json) {
    return SpuStockInfo(
      spuId: json['spuID'] ?? json['spuId'] ?? 0,
      stock: json['stock'] ?? 0,
      lockStock: json['lockStock'] ?? 0,
      saleStock: json['saleStock'] ?? 0,
    );
  }
}

abstract class ProductRemoteDataSource {
  Future<Result<List<ProductModel>>> getProductList(ProductListParams params);
  Future<Result<List<ProductModel>>> searchProducts(String keyword);
  Future<Result<List<ProductPriceModel>>> getProductPriceList(List<int> productIds);
  Future<Result<ProductSelectBaseResult>> getProductSelectBase();
  Future<Result<SkuSelectBaseResult>> getSkuSelectBase();
  Future<Result<ServeListResult>> getServeList();
  Future<Result<List<MallCategoryModel>>> getMallCategoryList();
  Future<Result<List<SpuModel>>> getSpuListByMallCate(int mallCateId);
  Future<Result<List<SkuModel>>> getSkuBySpu(int spuId);
  Future<Result<List<SpuStockInfo>>> getSpuStock(List<int> spuIds);
  /// 根据 SPU ID 获取商品详情（含 hasSerial 字段）
  Future<Result<ProductModel?>> getProductBySpuId(int spuId);
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
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.productPriceList,
      queryParameters: {'productIDs': productIds},
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
    // 1. 获取商城分类列表（3级结构：品类 -> 品牌 -> 系列）
    final categoryResponse = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mallCategoryList,
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

    // 解析商城分类列表
    final categoryList = categoryData['data'] as List<dynamic>? ?? categoryData['list'] as List<dynamic>? ?? [];
    final mallCategories = categoryList
        .whereType<Map<String, dynamic>>()
        .map((json) => MallCategoryModel.fromJson(json))
        .toList();

    // 构建商城分类树
    final mallCategoryTreeResult = _buildMallCategoryTree(mallCategories);
    final mallCategoryTree = mallCategoryTreeResult.$1;
    final nodeMap = mallCategoryTreeResult.$2;

    // 解析 SKU 数据，按 mallThirdCate[] 分组 SPU
    // 关键：mallThirdCate 是 SKU 所属的商城3级分类 ID 数组，与 MallCategoryTreeNode.id 对应
    final resList = skuData['res'] as List<dynamic>? ?? [];

    // 数据结构: Map<mallThirdCateId, Map<spuId, { spuName, skus }>>
    final spuByMallCate = <int, Map<int, _SpuData>>{};
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
      final mallThirdCateRaw = item['mallThirdCate'];
      final List<int> mallThirdCate;
      if (mallThirdCateRaw is List) {
        mallThirdCate = mallThirdCateRaw.whereType<int>().toList();
      } else {
        mallThirdCate = [];
      }

      if (spuId == 0 || mallThirdCate.isEmpty) continue;

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

      // 按商城3级分类分组 SPU（一个 SKU 可能属于多个3级分类）
      for (final cateId in mallThirdCate) {
        spuByMallCate.putIfAbsent(cateId, () => {});
        final spuMap = spuByMallCate[cateId]!;
        spuMap.putIfAbsent(spuId, () => _SpuData(spuName: spuName, skus: []));
        spuMap[spuId]!.skus.add(sku);
      }
    }

    // 将 SPU 关联到叶子分类节点（3级分类的 id 对应 MallCategoryTreeNode.id）
    for (final entry in spuByMallCate.entries) {
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
        final index = mallCategoryTree.indexWhere((n) => n.id == cateId);
        if (index >= 0) {
          mallCategoryTree[index] = node.copyWith(spus: spus);
        }
        nodeMap[cateId] = node.copyWith(spus: spus);
      }
    }

    // 扁平化为 CategoryWithSpu 列表（只显示有商品的叶子分类）
    final flatCategories = _flattenMallCategoryTree(mallCategoryTree);

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

  /// 构建商城分类树（3级结构：品类 -> 品牌 -> 系列）
  /// 返回 (树列表, 节点映射)
  (List<MallCategoryTreeNode>, Map<int, MallCategoryTreeNode>) _buildMallCategoryTree(
    List<MallCategoryModel> categories,
  ) {
    final nodeMap = <int, MallCategoryTreeNode>{};
    final topLevelNodes = <MallCategoryTreeNode>[];

    // 创建所有节点
    for (final cat in categories) {
      nodeMap[cat.id] = MallCategoryTreeNode(
        id: cat.id,
        title: cat.title,
        level: cat.level,
        pids: cat.pids,
      );
    }

    // 构建树
    // Level 1 品类：pids=[]，顶级
    // Level 2 品牌：pids=[品类ID]
    // Level 3 系列：pids=[品类ID, 品牌ID]
    for (final cat in categories) {
      final node = nodeMap[cat.id]!;

      if (cat.level == 1) {
        // 品类是顶级
        topLevelNodes.add(node);
      } else if (cat.level == 2 && cat.pids.isNotEmpty) {
        // 品牌挂在品类下
        final parentId = cat.pids[0];
        final parent = nodeMap[parentId];
        if (parent != null) {
          final children = List<MallCategoryTreeNode>.from(parent.children);
          children.add(node);
          nodeMap[parentId] = parent.copyWith(children: children);
        } else {
          topLevelNodes.add(node);
        }
      } else if (cat.level == 3 && cat.pids.length >= 2) {
        // 系列挂在品牌下
        final brandId = cat.pids[1];
        final parent = nodeMap[brandId];
        if (parent != null) {
          final children = List<MallCategoryTreeNode>.from(parent.children);
          children.add(node);
          nodeMap[brandId] = parent.copyWith(children: children);
        } else {
          // 品牌不存在则挂在品类下
          final categoryId = cat.pids[0];
          final category = nodeMap[categoryId];
          if (category != null) {
            final children = List<MallCategoryTreeNode>.from(category.children);
            children.add(node);
            nodeMap[categoryId] = category.copyWith(children: children);
          }
        }
      }
    }

    return (topLevelNodes, nodeMap);
  }

  /// 扁平化商城分类树为列表（只显示有商品的叶子分类）
  List<CategoryWithSpu> _flattenMallCategoryTree(List<MallCategoryTreeNode> nodes) {
    final result = <CategoryWithSpu>[];

    for (final node in nodes) {
      if (node.level == 3) {
        // 3级分类（系列）是叶子节点
        if (node.spus.isNotEmpty) {
          result.add(CategoryWithSpu(
            id: node.id,
            name: node.title,
            spus: node.spus,
          ));
        }
      } else if (node.children.isNotEmpty) {
        // 非叶子节点，递归处理子节点
        final childCategories = _flattenMallCategoryTree(node.children);
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

  @override
  Future<Result<List<MallCategoryModel>>> getMallCategoryList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mallCategoryList,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>?
          ?? data['list'] as List<dynamic>?
          ?? data['res'] as List<dynamic>?
          ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => MallCategoryModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Result<List<SpuModel>>> getSpuListByMallCate(int mallCateId) async {
    // 使用 queryParameters 传递数组参数，Dio 会正确处理
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.spuListByMallCate,
      queryParameters: {'mallCateIDs': mallCateId},
      parser: (data) => data,
    );

    // 处理响应错误
    if (response.isFailure) {
      return Failure(response.failure!);
    }

    final data = response.value!;

    // API 返回格式: {"code":10000,"list":[...]}
    final list = data['list'] as List<dynamic>?
        ?? data['data'] as List<dynamic>?
        ?? data['res'] as List<dynamic>?
        ?? [];
    var spus = list
        .whereType<Map<String, dynamic>>()
        .map((json) => SpuModel.fromJson(json))
        .toList();

    // 获取所有 SKU ID
    final skuIds = <int>[];
    for (final spu in spus) {
      for (final sku in spu.skus) {
        if (sku.skuId > 0) skuIds.add(sku.skuId);
      }
    }

    // 如果有 SKU，获取价格信息
    if (skuIds.isNotEmpty) {
      final priceResult = await getProductPriceList(skuIds);
      if (priceResult.isSuccess && priceResult.value != null) {
        final priceMap = <int, int>{};
        for (final p in priceResult.value!) {
          priceMap[p.productId] = p.price;
        }

        // 填充价格到 SKU
        spus = spus.map((spu) {
          final updatedSkus = spu.skus.map((sku) {
            final price = priceMap[sku.skuId];
            if (price != null && price > 0) {
              return sku.copyWith(retailPrice: price);
            }
            return sku;
          }).toList();

          // 计算 SPU 的最低和最高价格
          int? minPrice;
          int? maxPrice;
          for (final sku in updatedSkus) {
            final p = sku.retailPrice ?? 0;
            if (p > 0) {
              if (minPrice == null || p < minPrice) minPrice = p;
              if (maxPrice == null || p > maxPrice) maxPrice = p;
            }
          }

          return spu.copyWith(
            skus: updatedSkus,
            minPrice: minPrice,
            maxPrice: maxPrice,
            retailPrice: minPrice,
          );
        }).toList();
      }
    }

    return Success(spus);
  }

  @override
  Future<Result<List<SkuModel>>> getSkuBySpu(int spuId) async {
    // 使用 queryParameters 传递参数，注意参数名是 spuID (大写 D)
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.skuBySpu,
      queryParameters: {'spuID': spuId},
      parser: (data) => data,
    );

    return response.map((data) {
      // 安全解析列表，防止 API 返回单个对象而非数组导致崩溃
      List<dynamic>? parseList(dynamic raw) {
        if (raw is List) return raw;
        return null;
      }

      final list = parseList(data['data'])
          ?? parseList(data['list'])
          ?? parseList(data['skuList'])
          ?? parseList(data['skus'])
          ?? parseList(data['res'])
          ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => SkuModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Result<List<SpuStockInfo>>> getSpuStock(List<int> spuIds) async {
    if (spuIds.isEmpty) {
      return const Success([]);
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.spuGetStock,
      data: {'spuIDs': spuIds},
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>?
          ?? data['list'] as List<dynamic>?
          ?? data['res'] as List<dynamic>?
          ?? data['result'] as List<dynamic>?
          ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => SpuStockInfo.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Result<ProductModel?>> getProductBySpuId(int spuId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.productList,
      queryParameters: {'spuId': spuId.toString()},
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      if (list.isEmpty) return null;
      final first = list.first as Map<String, dynamic>?;
      if (first == null) return null;
      return ProductModel.fromJson(first);
    });
  }
}