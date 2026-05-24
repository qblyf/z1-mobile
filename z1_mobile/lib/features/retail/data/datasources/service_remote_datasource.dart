import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../models/service_model.dart';

class ServiceSelectResult {
  final List<ServiceModel> services;
  final List<ServiceCategoryModel> categories;

  const ServiceSelectResult({
    required this.services,
    required this.categories,
  });
}

abstract class ServiceRemoteDataSource {
  /// 获取服务分类（进销存分类，type=7）
  Future<Result<List<ServiceCategoryModel>>> getServiceCategories();
  
  /// 获取子级分类
  Future<Result<List<ServiceCategoryModel>>> getCategoryChildren(int parentId);
  
  /// 获取服务列表（可选按分类筛选）
  Future<Result<List<ServiceModel>>> getServeList({
    int? cateID,
    String? keyWord,
    bool includeChild = false,
  });
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiClient apiClient;

  ServiceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<ServiceCategoryModel>>> getServiceCategories() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.categoryList(type: 7),
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list.map((json) => ServiceCategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
  
  @override
  Future<Result<List<ServiceCategoryModel>>> getCategoryChildren(int parentId) async {
    final result = await getServiceCategories();
    
    if (result.isFailure) {
      return Failure(result.failure!);
    }
    
    final allCategories = result.value!;
    final children = allCategories.where((c) => c.parentId == parentId).toList();
    children.sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));
    
    return Success(children);
  }

  @override
  Future<Result<List<ServiceModel>>> getServeList({
    int? cateID,
    String? keyWord,
    bool includeChild = false,
  }) async {
    final queryParams = <String, dynamic>{
      if (cateID != null) 'cateID': cateID,
      if (keyWord != null && keyWord.isNotEmpty) 'keyWord': keyWord,
      'includeChild': includeChild,
      'states': [1],
      'limit': 100,
    };
    
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.serveList,
      queryParameters: queryParams,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? data['list'] as List<dynamic>? ?? [];
      return list.map((json) => ServiceModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}
