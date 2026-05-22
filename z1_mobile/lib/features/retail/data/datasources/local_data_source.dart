import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';
import 'product_remote_datasource.dart';
import 'service_remote_datasource.dart';

/// 本地数据缓存源
/// 1小时过期策略
class LocalProductDataSource {
  final SharedPreferences _prefs;
  
  static const String _productCacheKey = 'product_select_base_cache';
  static const String _skuCacheKey = 'sku_select_base_cache';
  static const Duration _cacheExpiration = Duration(hours: 1);

  LocalProductDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  /// 检查商品选择缓存是否有效
  bool isProductCacheValid() {
    return _isCacheValid(_productCacheKey);
  }

  /// 检查SKU选择缓存是否有效
  bool isSkuCacheValid() {
    return _isCacheValid(_skuCacheKey);
  }

  /// 获取缓存的商品选择数据
  ProductSelectBaseResult? getProductSelectBaseCache() {
    return _getCache<ProductSelectBaseResult>(
      _productCacheKey,
      (json) => ProductSelectBaseResult(
        products: (json['products'] as List<dynamic>?)
                ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        categories: (json['categories'] as List<dynamic>?)
                ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      ),
    );
  }

  /// 缓存商品选择数据
  Future<void> cacheProductSelectBase(ProductSelectBaseResult data) async {
    await _setCache(_productCacheKey, {
      'products': data.products.map((e) => e.toJson()).toList(),
      'categories': data.categories.map((e) => e.toJson()).toList(),
    });
  }

  /// 获取缓存的SKU选择数据
  SkuSelectBaseResult? getSkuSelectBaseCache() {
    final jsonStr = _prefs.getString(_skuCacheKey);
    if (jsonStr == null) return null;
    
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SkuSelectBaseResult.fromJson(json);
    } catch (e) {
      // 缓存数据损坏，返回null
      return null;
    }
  }

  /// 缓存SKU选择数据
  Future<void> cacheSkuSelectBase(SkuSelectBaseResult data) async {
    final categoriesJson = data.categories.map((e) => _categoryWithSpuToJson(e)).toList();
    final cacheData = {
      'categories': categoriesJson,
    };
    await _setCache(_skuCacheKey, cacheData);
  }

  /// 清除所有商品缓存
  Future<void> clearCache() async {
    await _prefs.remove(_productCacheKey);
    await _prefs.remove(_skuCacheKey);
  }

  bool _isCacheValid(String key) {
    final timestamp = _prefs.getInt('$key\_timestamp');
    if (timestamp == null) return false;
    
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cachedTime) < _cacheExpiration;
  }

  T? _getCache<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      // 缓存数据损坏，返回null
      return null;
    }
  }

  Future<void> _setCache(String key, Map<String, dynamic> data) async {
    final jsonStr = jsonEncode(data);
    await _prefs.setString(key, jsonStr);
    await _prefs.setInt('$key\_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  /// 将 CategoryWithSpu 转换为 Map
  Map<String, dynamic> _categoryWithSpuToJson(CategoryWithSpu cat) {
    return {
      'id': cat.id,
      'name': cat.name,
      'parentId': cat.parentId,
      'spuList': cat.spus.map((spu) => _spuModelToJson(spu)).toList(),
    };
  }

  /// 将 SpuModel 转换为 Map
  Map<String, dynamic> _spuModelToJson(SpuModel spu) {
    return {
      'spuId': spu.spuId,
      'name': spu.spuName,
      'spuName': spu.spuName,
      'retailPrice': spu.retailPrice,
      'memberPrice': spu.memberPrice,
      'stock': spu.stock,
      'image': spu.image,
      'categoryName': spu.categoryName,
      'skuList': spu.skus.map((sku) => _skuModelToJson(sku)).toList(),
    };
  }

  /// 将 SkuModel 转换为 Map
  Map<String, dynamic> _skuModelToJson(SkuModel sku) {
    return {
      'skuId': sku.skuId,
      'skuName': sku.skuName,
      'name': sku.skuName,
      'price': sku.price,
      'retailPrice': sku.retailPrice,
      'memberPrice': sku.memberPrice,
      'stock': sku.stock,
      'unit': sku.unit,
      'image': sku.image,
      'specs': sku.specs,
    };
  }
}

/// 本地服务数据缓存源
/// 1小时过期策略
class LocalServiceDataSource {
  final SharedPreferences _prefs;
  
  static const String _cacheKey = 'service_select_base_cache';
  static const Duration _cacheExpiration = Duration(hours: 1);

  LocalServiceDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  /// 检查服务缓存是否有效
  bool isCacheValid() {
    return _isCacheValid(_cacheKey);
  }

  /// 获取缓存的服务选择数据
  ServiceSelectResult? getServiceSelectBaseCache() {
    return _getCache<ServiceSelectResult>(
      _cacheKey,
      (json) => ServiceSelectResult(
        services: (json['services'] as List<dynamic>?)
                ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        categories: (json['categories'] as List<dynamic>?)
                ?.map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      ),
    );
  }

  /// 缓存服务选择数据
  Future<void> cacheServiceSelectBase(ServiceSelectResult data) async {
    await _setCache(_cacheKey, {
      'services': data.services.map((e) => e.toJson()).toList(),
      'categories': data.categories.map((e) => e.toJson()).toList(),
    });
  }

  /// 清除所有服务缓存
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
  }

  bool _isCacheValid(String key) {
    final timestamp = _prefs.getInt('$key\_timestamp');
    if (timestamp == null) return false;
    
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cachedTime) < _cacheExpiration;
  }

  T? _getCache<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      // 缓存数据损坏，返回null
      return null;
    }
  }

  Future<void> _setCache(String key, Map<String, dynamic> data) async {
    final jsonStr = jsonEncode(data);
    await _prefs.setString(key, jsonStr);
    await _prefs.setInt('$key\_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}

/// 扩展方法：转换为可JSON格式
extension ProductModelToJson on ProductModel {
  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'price': price,
      'category': category,
      'code': code,
      'genre': genre,
      'categoryName': categoryName,
      'barcode': barcode,
      'retailPrice': retailPrice,
      'memberPrice': memberPrice,
      'stock': stock,
      'image': image,
      'unit': unit,
    };
  }
}

extension CategoryModelToJson on CategoryModel {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'sort': sort,
    };
  }
}

extension ServiceModelToJson on ServiceModel {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'price': price,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isGoods': isGoods,
    };
  }
}

extension ServiceCategoryModelToJson on ServiceCategoryModel {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'sort': sort,
    };
  }
}