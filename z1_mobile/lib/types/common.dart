// ============================================================
// Common Types - 基础类型定义
// 从 z1-mid SDK 类型翻译而来
// DO NOT EDIT MANUALLY
// ============================================================

// ============================================================
// 基础类型别名
// ============================================================

/// 通用 ID 类型
typedef SkuID = int;
typedef SpuID = int;
typedef CateID = int;
typedef MallCategoryID = int;
typedef MemberID = int;
typedef OrderID = int;
typedef WarehouseID = int;
typedef DepartmentID = int;
typedef TransferID = int;
typedef GoodsID = int;
typedef ServiceID = int;
typedef AuthID = int;

/// 用户标识
typedef UserIdent = String;

/// JWT Token 类型
typedef JWT = String;

/// RMB 金额（单位：分）
typedef RMBFen = int;

/// Unix 时间戳
typedef UnixTimestamp = int;

// ============================================================
// 枚举类型
// ============================================================

/// 会员状态
enum MemberState {
  normal(1),
  disabled(2),
  unverified(0);

  final int value;
  const MemberState(this.value);
  
  static MemberState fromValue(int value) {
    return MemberState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MemberState.normal,
    );
  }
}

/// 商品状态
enum ProductState {
  offShelf(0),
  onShelf(1);

  final int value;
  const ProductState(this.value);
  
  static ProductState fromValue(int value) {
    return ProductState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductState.offShelf,
    );
  }
}

/// 销售状态
enum SalesState {
  notForSale(0),
  forSale(1);

  final int value;
  const SalesState(this.value);
  
  static SalesState fromValue(int value) {
    return SalesState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SalesState.notForSale,
    );
  }
}

/// 是否有序列号
enum ProductHasSerial {
  no(0),
  yes(1);

  final int value;
  const ProductHasSerial(this.value);
  
  static ProductHasSerial fromValue(int value) {
    return ProductHasSerial.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductHasSerial.no,
    );
  }
}

// ============================================================
// 通用响应类型
// ============================================================

/// 通用响应包装
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? code;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] as T?,
      error: json['error'] as String?,
      code: json['code'] as int?,
    );
  }
}

/// Z1 API 响应格式（{code, res, message}）
class Z1ApiResponse<T> {
  final int code;
  final T? res;
  final String? message;

  Z1ApiResponse({
    required this.code,
    this.res,
    this.message,
  });

  bool get isSuccess => code == 10000;

  factory Z1ApiResponse.fromJson(Map<String, dynamic> json) {
    return Z1ApiResponse(
      code: json['code'] as int? ?? 0,
      res: json['res'] as T?,
      message: json['message'] as String?,
    );
  }
}

/// 分页响应
class PaginatedResponse<T> {
  final List<T> list;
  final int total;
  final int page;
  final int pageSize;

  PaginatedResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }
}

// ============================================================
// 操作结果类型
// ============================================================

/// 操作结果
class Result<T> {
  final T? value;
  final Failure? failure;

  Result.success(this.value) : failure = null;
  Result.failure(this.failure) : value = null;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;
}

/// 失败信息
class Failure {
  final String message;
  final int? code;
  final FailureType type;

  Failure({
    required this.message,
    this.code,
    this.type = FailureType.unknown,
  });
}

enum FailureType {
  networkError,
  serverError,
  unauthorized,
  notFound,
  validationError,
  unknown,
}
