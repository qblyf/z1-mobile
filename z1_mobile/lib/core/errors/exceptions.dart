/// 自定义异常
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message';
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException({super.message = '缓存异常'});
}

/// 存储异常
class StorageException extends AppException {
  const StorageException({super.message = '存储异常'});
}

/// 扫码异常
class ScannerException extends AppException {
  const ScannerException({super.message = '扫码异常'});
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException({super.message = '权限不足'});
}

/// 参数异常
class ValidationException extends AppException {
  const ValidationException({super.message = '参数错误'});
}