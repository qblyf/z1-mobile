import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../types/api/mall-order-types.dart';
import '../data/models/mall_order_model.dart';

/// 商城订单页面共享的展示工具
///
/// 列表页与详情页都用这里的工具函数，确保配色 / 时间格式一致；
/// 之前列表页与详情页各写一份配色，因为分组不同导致状态徽章不一致。

/// Unix 秒 → `yyyy-MM-dd HH:mm`（无效输入返回空串）
String formatMallOrderTime(int unixSeconds) {
  if (unixSeconds <= 0) return '';
  final dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  return DateFormat('yyyy-MM-dd HH:mm').format(dt);
}

/// 按展示层 6 tab 分组的徽章配色：(背景, 前景)
///
/// 与 `MallOrderDisplayStatus` 一一对应。新增协议层 status 时，
/// `MallOrderDisplayStatus.fromMallOrderStatus` 会负责归类，本函数不必改。
(Color bg, Color fg) mallOrderStatusColors(MallOrderStatus status) {
  final group = MallOrderDisplayStatus.fromMallOrderStatus(status);
  switch (group) {
    case MallOrderDisplayStatus.completed:
      return (const Color(0xFFDCFCE7), const Color(0xFF16A34A));
    case MallOrderDisplayStatus.refunded:
      return (const Color(0xFFFEE2E2), const Color(0xFFDC2626));
    case MallOrderDisplayStatus.shipped:
      return (const Color(0xFFDBEAFE), const Color(0xFF2563EB));
    case MallOrderDisplayStatus.paid:
      return (const Color(0xFFFEF3C7), const Color(0xFFD97706));
    case MallOrderDisplayStatus.pendingPay:
      return (const Color(0xFFFFE4E6), const Color(0xFFE11D48));
    case MallOrderDisplayStatus.all:
      return (const Color(0xFFF3F4F6), const Color(0xFF374151));
  }
}
