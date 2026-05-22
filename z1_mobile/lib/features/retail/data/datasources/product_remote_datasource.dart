import 'package:equatable/equatable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/product_model.dart';

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
    // 直接调用 /product/select-base 接口（不再使用 z1func 中间层）
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.productSelectBase,
      parser: (data) => data,
    );

    return response.map((data) {
      // 将 product/select-base 返回数据映射为 SkuSelectBaseResult 格式
      final productList = data['productList'] as List<dynamic>? ?? [];
      final categoryList = data['categoryList'] as List<dynamic>? ?? [];

      // 构建 CategoryWithSpu 结构
      final categories = <CategoryWithSpu>[];

      // 按分类分组商品
      final productsByCategory = <int, List<ProductModel>>{};
      for (final item in productList) {
        if (item is Map<String, dynamic>) {
          final product = ProductModel.fromJson(item);
          final categoryId = product.categoryId ?? 0;
          productsByCategory.putIfAbsent(categoryId, () => []).add(product);
        }
      }

      // 添加"全部商品"分类（包含所有商品）
      if (productList.isNotEmpty) {
        final allProducts = productList
            .map((item) => item is Map<String, dynamic> ? ProductModel.fromJson(item) : null)
            .whereType<ProductModel>()
            .toList();

        categories.add(CategoryWithSpu(
          id: 0,
          name: '全部商品',
          spus: [
            SpuModel(
              spuId: 0,
              spuName: '全部商品',
              skus: allProducts.map((p) => SkuModel.fromProduct(p)).toList(),
            ),
          ],
        ));
      }

      // 添加按分类分组的分类
      for (final categoryJson in categoryList) {
        if (categoryJson is Map<String, dynamic>) {
          final category = CategoryModel.fromJson(categoryJson);
          final categoryProducts = productsByCategory[category.id] ?? [];
          if (categoryProducts.isNotEmpty) {
            categories.add(CategoryWithSpu(
              id: category.id,
              name: category.name,
              spus: [
                SpuModel(
                  spuId: category.id,
                  spuName: category.name,
                  skus: categoryProducts.map((p) => SkuModel.fromProduct(p)).toList(),
                ),
              ],
            ));
          }
        }
      }

      return SkuSelectBaseResult(categories: categories);
    });
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