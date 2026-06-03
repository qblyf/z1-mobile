import 'package:equatable/equatable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/result.dart';
import '../models/mall_order_detail_model.dart';
import '../models/mall_order_model.dart';

/// 商城订单列表请求参数
///
/// `status` 实际由展示层 6 tab 决定（参考 `MallOrderDisplayStatus.apiStatusValues`）。
///
/// ⚠️ 后端真实分页/筛选格式（2026-05-29 实测）：
/// - **分页**：`offset + limit`，**不是** `page + pageSize`。
///   `pageSize` / `size` / `perPage` 都会被忽略（永远返回 100 条上限）；
///   `page` 也被忽略（page=1/2/999 返回同样结果）。
///   只有 `offset` 和 `limit` 真正生效。
/// - **状态筛选**：`status=21,22,23` 逗号分隔字符串，**不是** `status[]=...` 数组，
///   也不是 JSON 字符串。`all` tab 不传该参数。
///
/// 本类对外仍暴露 `page + pageSize` 的概念（与其它 datasource 对齐），内部转换为
/// `offset + limit`。
class MallOrderListParams extends Equatable {
  final int page; // 从 1 开始
  final int pageSize;
  final List<int> status;

  const MallOrderListParams({
    this.page = 1,
    this.pageSize = 20,
    this.status = const [],
  });

  Map<String, dynamic> toQueryParams() {
    final offset = (page - 1) * pageSize;
    return {
      'offset': offset,
      'limit': pageSize,
      if (status.isNotEmpty) 'status': status.join(','),
    };
  }

  @override
  List<Object?> get props => [page, pageSize, status];
}

/// 商城订单列表 datasource
///
/// ⚠️ 真实响应包装（2026-05-29 空跑确认）：
/// ```
/// { "code": 10000, "res": [ ...items ] }
/// ```
/// 与 `/shopSale/list` 的 `{ code, res: { data: [...] } }` 不同 —— 这里 `res`
/// 直接是数组，不再嵌一层。datasource 手动剥 `code/res`，业务码非 10000 直接转
/// `Failure`。
abstract class MallOrderRemoteDataSource {
  Future<Result<List<MallOrderModel>>> getMallOrderList(
    MallOrderListParams params,
  );

  /// 商城订单详情
  ///
  /// ⚠️ 接口签名实测（2026-05-29，环境 z1-fun.zsqk.com.cn/deno）：
  /// - 方法：**GET**（POST 返回 `90000 请求方法无效`）
  /// - 参数名：**`mallOrderNumbers`**（复数 + 逗号串），不是单数 `mallOrderID`/
  ///   `number`/`id`。任何其它参数名一律返回 `90002 参数类型有误`。
  /// - 支持批量：`mallOrderNumbers=NUM1,NUM2`，返回 `res: MallOrder[]` 顺序对应。
  /// - 订单不存在：返回 `{code:10000, res:[]}`（**不是** HTTP 错误），上层取
  ///   `res[0]`，空则视为 NotFound。
  Future<Result<MallOrderDetailModel>> getMallOrderDetail(String number);

  /// 完成商城订单（自提送出后店员标记）
  ///
  /// 后端 `MallOrderFinish` 类型签名（z1-mid/src/types/mall-order-fn-types.ts:939）：
  /// - 方法：POST `/mall-order/finish`
  /// - body：`{ mallOrderNumber: string, code?: string }`（**单数** `mallOrderNumber`，
  ///   注意与详情接口 `mallOrderNumbers` 复数不一致）
  /// - 返回：`{ code, res: number }`（受影响的行数，>0 即成功）
  ///
  /// ⚠️ 真实接口尚未空跑 —— 破坏性接口（会改订单状态），上线前需业务方提供
  /// 可作废的测试订单做一次空跑验证 `mallOrderNumber` 参数名是否真的生效。
  Future<Result<int>> finishMallOrder(String number, {String? code});

  /// 取消待支付商城订单
  ///
  /// 后端 `MallOrderCancel` 类型签名（z1-mid/src/types/mall-order-fn-types.ts:999）：
  /// - 方法：POST `/mall-order/unpaid-cancel`
  /// - body：`{ mallOrderNumber: string, remarks?: string }`
  /// - 返回：`{ code, res: number }`
  ///
  /// ⚠️ 同 [finishMallOrder]，破坏性接口，参数名未空跑。
  Future<Result<int>> cancelUnpaidOrder(String number, {String? remarks});
}

class MallOrderRemoteDataSourceImpl implements MallOrderRemoteDataSource {
  final ApiClient apiClient;

  MallOrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<List<MallOrderModel>>> getMallOrderList(
    MallOrderListParams params,
  ) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/mall-order/list',
      queryParameters: params.toQueryParams(),
      parser: (data) => data as Map<String, dynamic>,
    );
    return _unwrapRes(response, (res) {
      final list = (res as List<dynamic>?) ?? const [];
      return list
          .map((j) => MallOrderModel.fromJson(j as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Result<MallOrderDetailModel>> getMallOrderDetail(String number) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/mall-order/detail',
      queryParameters: {'mallOrderNumbers': number},
      parser: (data) => data as Map<String, dynamic>,
    );
    return _unwrapRes(response, (res) {
      final list = (res as List<dynamic>?) ?? const [];
      if (list.isEmpty) {
        throw const _NotFound('订单不存在');
      }
      return MallOrderDetailModel.fromJson(
        list.first as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<Result<int>> finishMallOrder(String number, {String? code}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/mall-order/finish',
      data: {
        'mallOrderNumber': number,
        if (code != null && code.isNotEmpty) 'code': code,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
    return _unwrapRes(response, (res) => (res as num?)?.toInt() ?? 0);
  }

  @override
  Future<Result<int>> cancelUnpaidOrder(String number, {String? remarks}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/mall-order/unpaid-cancel',
      data: {
        'mallOrderNumber': number,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
    return _unwrapRes(response, (res) => (res as num?)?.toInt() ?? 0);
  }

  /// 把 `{ code, res }` 包装统一剥成 `Result<T>`：
  /// - HTTP/网络层 Failure 直传
  /// - `code != 10000` → `Failure(serverError(message))`
  /// - 业务层抛 [_NotFound] → `Failure(serverError(msg))`（详情等场景用空数组当 404）
  Result<T> _unwrapRes<T>(
    Result<Map<String, dynamic>> response,
    T Function(dynamic res) extract,
  ) {
    if (response.isFailure) return Failure(response.failure!);
    final data = response.value!;
    final code = data['code'] as int?;
    if (code != null && code != 10000) {
      final msg = (data['message'] ?? data['msg'] ?? '请求失败') as String;
      return Failure(ApiFailure.serverError(msg));
    }
    try {
      return Success(extract(data['res']));
    } on _NotFound catch (e) {
      return Failure(ApiFailure.serverError(e.message));
    }
  }
}

/// datasource 内部信号：业务码 10000 但语义上资源不存在（如详情返回空数组）
class _NotFound implements Exception {
  final String message;
  const _NotFound(this.message);
}
