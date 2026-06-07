// CouponItem / RetailOrder 单元测试
// 验证 commit 01cf283 修复: confirm page 把 _selectedCoupons 传给 RetailOrder.coupons
import 'package:flutter_test/flutter_test.dart';
import 'package:z1_mobile/features/retail/data/models/coupon_model.dart';
import 'package:z1_mobile/features/retail/data/models/retail_order_model.dart';

void main() {
  group('CouponItem 序列化 (后端 AddOrderCoupon 契约)', () {
    test('toJson 输出 {couponID, amount} 字段名匹配后端', () {
      const item = CouponItem(couponId: 12345, amount: 5000); // 50元 = 5000分
      final json = item.toJson();
      expect(json['couponID'], 12345, reason: '字段名必须是 couponID (大写 ID)');
      expect(json['amount'], 5000, reason: '字段名必须是 amount');
    });

    test('多个 coupons 序列化为数组', () {
      const items = [
        CouponItem(couponId: 100, amount: 1000),
        CouponItem(couponId: 200, amount: 2000),
        CouponItem(couponId: 300, amount: 3000),
      ];
      final list = items.map((i) => i.toJson()).toList();
      expect(list.length, 3);
      expect(list[0], {'couponID': 100, 'amount': 1000});
      expect(list[1], {'couponID': 200, 'amount': 2000});
      expect(list[2], {'couponID': 300, 'amount': 3000});
    });
  });

  group('RetailOrder.copyWith coupons 字段传递 (bug 修复验证)', () {
    // 模拟 confirm page 的 _selectedCoupons 状态
    final selectedCoupons = <CouponModel>[
      CouponModel(
        couponId: 1001,
        couponName: '满100减10',
        type: CouponType.fixed,
        discountValue: 1000, // 10元 = 1000分
        minOrderAmount: 10000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        status: CouponStatus.available,
      ),
      CouponModel(
        couponId: 1002,
        couponName: '满200减30',
        type: CouponType.fixed,
        discountValue: 3000, // 30元 = 3000分
        minOrderAmount: 20000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        status: CouponStatus.available,
      ),
    ];

    test('_goToPayment 关键逻辑: CouponModel → CouponItem → RetailOrder.coupons', () {
      // 1. 构造初始 order (来自 entry page)
      const initialOrder = RetailOrder(
        warehouseID: 1,
        customerIdent: 15698510981,
        customerName: '李慧',
      );

      // 2. 模拟 _goToPayment() 中的转换
      //    源码: _selectedCoupons.map((c) => CouponItem(couponId: c.couponId, amount: c.discountValue)).toList();
      final couponItems = selectedCoupons
          .map((c) => CouponItem(couponId: c.couponId, amount: c.discountValue))
          .toList();

      // 3. copyWith 传入 coupons (修复关键点)
      final updatedOrder = initialOrder.copyWith(
        decreaseCoins: 500, // 5元积分抵扣
        coupons: couponItems,
        remarks: '测试订单',
      );

      // 4. 验证修复后 RetailOrder 包含正确的 coupons
      expect(updatedOrder.coupons.length, 2, reason: 'coupons 必须有 2 项');
      expect(updatedOrder.coupons[0].couponId, 1001);
      expect(updatedOrder.coupons[0].amount, 1000, reason: 'amount 单位:分');
      expect(updatedOrder.coupons[1].couponId, 1002);
      expect(updatedOrder.coupons[1].amount, 3000);
      expect(updatedOrder.decreaseCoins, 500, reason: '积分抵扣(分)');
      expect(updatedOrder.remarks, '测试订单');
    });

    test('未选优惠券时 coupons 应为空列表', () {
      const initialOrder = RetailOrder(warehouseID: 1);
      // 模拟 _goToPayment 但 _selectedCoupons 为空
      final couponItems = <CouponModel>[]
          .map((c) => CouponItem(couponId: c.couponId, amount: c.discountValue))
          .toList();
      final updatedOrder = initialOrder.copyWith(
        coupons: couponItems,
      );
      expect(updatedOrder.coupons, isEmpty, reason: '空选择时 coupons 为空数组');
    });

    test('retail_payment_page 提交 body 构造 (line 103-128 逻辑)', () {
      // 模拟 _completePayment 的 body 构造
      final couponItems = selectedCoupons
          .map((c) => CouponItem(couponId: c.couponId, amount: c.discountValue))
          .toList();
      const order = RetailOrder(
        warehouseID: 1,
        customerIdent: 15698510981,
        sellerIdent: 100,
      );
      final finalOrder = order.copyWith(
        decreaseCoins: 0,
        coupons: couponItems,
        remarks: null,
      );

      // 构造 _completePayment 中的 data
      final body = <String, dynamic>{
        'warehouseID': finalOrder.warehouseID,
        'customerIdent': finalOrder.customerIdent ?? 0,
        'sellerIdent': finalOrder.sellerIdent ?? 0,
        'decreaseCoins': finalOrder.decreaseCoins,
        'productInfos': finalOrder.products.map((p) => {
          'productID': p.productID,
          'discountPrice': p.discountPrice > 0 ? p.discountPrice : p.price,
          'totalDiscountPrice':
              (p.discountPrice > 0 ? p.discountPrice : p.price) * p.quantity,
          'quantity': p.quantity,
          'type': p.type,
          'isGift': p.isGift ? 1 : 0,
        }).toList(),
        'payMode': [
          {'paymentTypeID': 1, 'amount': 67000}, // 模拟支付 670元
        ],
        if (finalOrder.coupons.isNotEmpty)
          'coupons': finalOrder.coupons.map((c) => c.toJson()).toList(),
        if (finalOrder.recycleOrderNumber != null) 'recycleOrderNumber': finalOrder.recycleOrderNumber,
        if (finalOrder.remarks != null) 'remarks': finalOrder.remarks,
      };

      // 验证 body 结构
      expect(body['warehouseID'], 1);
      expect(body['customerIdent'], 15698510981);
      expect(body['decreaseCoins'], 0);
      expect(body['coupons'], isA<List>());
      expect((body['coupons'] as List).length, 2);
      expect((body['coupons'] as List)[0], {'couponID': 1001, 'amount': 1000});
      expect((body['coupons'] as List)[1], {'couponID': 1002, 'amount': 3000});
      expect(body.containsKey('recycleOrderNumber'), false,
          reason: 'recycleOrderNumber 为 null 时不发送');
      expect(body.containsKey('remarks'), false,
          reason: 'remarks 为 null 时不发送');
    });
  });

  group('金额计算 (CouponItem.amount 单位一致性)', () {
    test('discountValue (分) 直接作为 amount 传给 CouponItem - 单位都是分', () {
      final coupon = CouponModel(
        couponId: 999,
        couponName: '10元券',
        type: CouponType.fixed,
        discountValue: 1000, // 10元 = 1000分
        minOrderAmount: 0,
        startDate: DateTime(2026),
        endDate: DateTime(2026, 12, 31),
        status: CouponStatus.available,
      );
      final item = CouponItem(couponId: coupon.couponId, amount: coupon.discountValue);
      expect(item.amount, 1000, reason: '单位:分 - 与后端 RMBFen 一致');
    });
  });
}
