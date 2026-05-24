import 'package:equatable/equatable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/product_model.dart';

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
  Future<Result<List<CategoryModel>>> getCategoryList({int type = 1});
  Future<Result<List<SpuModel>>> getSpuListByCategory(int categoryId);
  Future<Result<ServeListResult>> getServeList();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<CategoryModel>>> getCategoryList({int type = 1}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.categoryList(type: type),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? 
          ?? data['list'] as List<dynamic>? 
          ?? data['res'] as List<dynamic>? 
          ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Result<List<SpuModel>>> getSpuListByCategory(int categoryId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.spuList(cateId: categoryId),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? 
          ?? data['list'] as List<dynamic>? 
          ?? data['res'] as List<dynamic>? 
          ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => SpuModel.fromJson(json))
          .toList();
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