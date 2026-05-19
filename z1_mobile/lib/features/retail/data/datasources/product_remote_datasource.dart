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

abstract class ProductRemoteDataSource {
  Future<Result<List<ProductModel>>> getProductList(ProductListParams params);
  Future<Result<List<ProductModel>>> searchProducts(String keyword);
  Future<Result<List<ProductPriceModel>>> getProductPriceList(List<int> productIds);
  Future<Result<ProductSelectBaseResult>> getProductSelectBase();
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
}