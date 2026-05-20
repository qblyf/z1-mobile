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
  Future<Result<List<ServiceModel>>> getServeList();
  Future<Result<ServiceSelectResult>> getServiceSelectBase();
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiClient apiClient;

  ServiceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<ServiceModel>>> getServeList() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.serveList,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((json) => ServiceModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<ServiceSelectResult>> getServiceSelectBase() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.serveList,
      parser: (data) => data,
    );

    return response.map((data) {
      final list = data['data'] as List<dynamic>? ?? [];

      final categoryMap = <int, String>{};
      final services = <ServiceModel>[];

      for (final json in list) {
        final service = ServiceModel.fromJson(json as Map<String, dynamic>);
        services.add(service);
        if (service.categoryId != null && service.categoryName != null) {
          categoryMap[service.categoryId!] = service.categoryName!;
        }
      }

      final categories = categoryMap.entries.map((e) {
        return ServiceCategoryModel(id: e.key, name: e.value);
      }).toList();

      return ServiceSelectResult(
        services: services,
        categories: categories,
      );
    });
  }
}