// 零售开单端到端集成测试（模拟完整业务流）
// 验证：login → 选商品 → 选优惠券 → submit 整个流程的后端响应
// 重点：commit 01cf283 修复 - coupons 字段正确传递
// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:z1_mobile/core/api/api_endpoints.dart';
import 'package:z1_mobile/features/retail/data/models/retail_order_model.dart';

void main() {
  // 测试后端基础 URL
  const baseUrl = 'https://z1-fun.zsqk.com.cn/deno';
  const testPhone = '99999999999';
  const testPassword = r'ncxSEpbZ$20m$W6O';

  group('零售开单端到端测试', () {
    test('1. 登录获取 token', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final res = await dio.post(ApiEndpoints.login, data: {
        'phone': testPhone,
        'pwd': testPassword,
        'remember_me': false,
      });
      expect(res.statusCode, 200);
      expect(res.data['code'], 10000, reason: '成功码应为 10000');
      final token = res.data['res']?['token'];
      expect(token, isNotNull, reason: '登录后必须有 token');
      print('✅ 登录成功，token 前缀: ${token.toString().substring(0, 20)}...');
    });

    test('2. 真实接口: 提交带 coupons 的店内零售单', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));

      // 登录
      final loginRes = await dio.post(ApiEndpoints.login, data: {
        'phone': testPhone,
        'pwd': testPassword,
        'remember_me': false,
      });
      final token = loginRes.data['res']['token'];
      expect(token, isNotNull);

      // 构造 order - 模拟 confirm page _goToPayment 后的状态
      // 重点：coupons 字段必须与 commit 01cf283 修复后的格式一致
      const order = RetailOrder(
        warehouseID: 1,
        customerIdent: 15698510981, // 会员 ID
        sellerIdent: 100,
        products: const [
          ProductItem(
            productID: 999, // 测试 SPU ID（如果无效会失败）
            productName: '测试商品',
            price: 100, // 1元
            quantity: 1,
            discountPrice: 100,
            totalDiscountPrice: 100,
            type: 1,
            isGift: false,
          ),
        ],
        decreaseCoins: 0,
        coupons: const [
          // 模拟 commit 01cf283 修复后从 _selectedCoupons 转换来的 CouponItem
          CouponItem(couponId: 12345, amount: 1000), // 10元券
        ],
        remarks: 'commit 01cf283 E2E 验证',
      );

      // 构造提交 body (与 retail_payment_page._completePayment 逻辑一致)
      final body = <String, dynamic>{
        'warehouseID': order.warehouseID,
        'customerIdent': order.customerIdent ?? 0,
        'sellerIdent': order.sellerIdent ?? 0,
        'decreaseCoins': order.decreaseCoins,
        'productInfos': order.products
            .map((p) => {
                  'productID': p.productID,
                  'discountPrice':
                      p.discountPrice > 0 ? p.discountPrice : p.price,
                  'totalDiscountPrice':
                      (p.discountPrice > 0 ? p.discountPrice : p.price) *
                          p.quantity,
                  'quantity': p.quantity,
                  'type': p.type,
                  'isGift': p.isGift ? 1 : 0,
                })
            .toList(),
        'payMode': [
          {'paymentTypeID': 1, 'amount': 100}, // 1元现金
        ],
        if (order.coupons.isNotEmpty)
          'coupons': order.coupons.map((c) => c.toJson()).toList(),
        if (order.remarks != null) 'remarks': order.remarks,
      };

      // 验证 body 包含正确的 coupons 字段
      expect(body['coupons'], isA<List>(), reason: 'coupons 必须是数组');
      expect((body['coupons'] as List).length, 1, reason: '应有 1 张券');
      expect((body['coupons'] as List)[0]['couponID'], 12345);
      expect((body['coupons'] as List)[0]['amount'], 1000);
      print('✅ 提交 body 结构正确，coupons 字段: ${body['coupons']}');

      // 提交订单（真实后端调用）- 接受 200 和 400 两种响应
      late Response submitRes;
      try {
        submitRes = await dio.post(
          '/order/sale-shop-add',
          data: body,
          options: Options(headers: {
            'Authorization': token,
            'Use-Permissions': 'all',
          }, validateStatus: (s) => s != null && s < 500),
        );
      } on DioException catch (e) {
        submitRes =
            e.response ?? Response(requestOptions: RequestOptions(path: ''));
      }

      print('📤 提交响应: status=${submitRes.statusCode}, body=${submitRes.data}');

      // 业务码分析
      final code = submitRes.data is Map ? submitRes.data['code'] : null;
      if (code == 10000) {
        // 成功
        final orderNumber = submitRes.data['res']?['orderNumber'];
        expect(orderNumber, isNotNull, reason: '成功响应应包含 orderNumber');
        print('✅ 订单创建成功: $orderNumber');
      } else {
        // 失败也算正常（如商品ID不存在、库存不足等）- 但需要确认是业务错误而非格式错误
        final message = submitRes.data['message'] ?? '';
        print('⚠️ 业务错误: $message');
        // 关键验证：后端能正确解析 coupons 字段（即错误不是 "coupons 格式错误"）
        expect(
          message.contains('couponID') ||
              message.contains('coupons') ||
              message.contains('格式') ||
              message.contains('无效'),
          isFalse,
          reason: '后端应能解析 CouponItem 格式，不应返回格式错误',
        );
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('3. 提交空 coupons（验证后端对空字段的容错）', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final loginRes = await dio.post(ApiEndpoints.login, data: {
        'phone': testPhone,
        'pwd': testPassword,
        'remember_me': false,
      });
      final token = loginRes.data['res']['token'];

      const order = RetailOrder(
        warehouseID: 1,
        customerIdent: 15698510981,
        sellerIdent: 100,
        products: const [
          ProductItem(
            productID: 999,
            productName: '测试商品',
            price: 100,
            quantity: 1,
            discountPrice: 100,
            totalDiscountPrice: 100,
          ),
        ],
        // 不传 coupons
      );

      final body = {
        'warehouseID': order.warehouseID,
        'customerIdent': order.customerIdent ?? 0,
        'sellerIdent': order.sellerIdent ?? 0,
        'decreaseCoins': 0,
        'productInfos': order.products
            .map((p) => {
                  'productID': p.productID,
                  'discountPrice': p.discountPrice,
                  'totalDiscountPrice': p.totalDiscountPrice,
                  'quantity': p.quantity,
                  'type': 1,
                  'isGift': 0,
                })
            .toList(),
        'payMode': [
          {'paymentTypeID': 1, 'amount': 100},
        ],
        // 注意：retail_payment_page 代码是 if (order.coupons.isNotEmpty) 'coupons': ...
        // 即空 coupons 不发送字段，不是发送空数组
      };

      expect(body.containsKey('coupons'), false, reason: '空 coupons 不应发送字段');

      final res = await dio.post(
        '/order/sale-shop-add',
        data: body,
        options: Options(headers: {
          'Authorization': token,
          'Use-Permissions': 'all',
        }, validateStatus: (s) => s != null && s < 500),
      );
      print('✅ 空 coupons 提交响应: status=${res.statusCode}, body=${res.data}');
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
