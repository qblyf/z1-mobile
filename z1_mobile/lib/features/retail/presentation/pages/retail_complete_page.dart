import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/retail_order_model.dart';

/// 订单完成页
class RetailCompletePage extends StatelessWidget {
  final RetailOrder order;

  const RetailCompletePage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // 成功提示
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeGreen,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '订单创建成功',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order.orderNumber != null)
                    Text(
                      '订单号：${order.orderNumber}',
                      style: const TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            // 订单摘要
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('订单金额'),
                      Text(
                        currencyFormat.format(order.productsTotalYuan),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('支付方式'),
                      Text(
                        order.payments.map((p) => _getPayMethodLabel(p.paymentTypeID)).join(' + '),
                        style: const TextStyle(color: CupertinoColors.secondaryLabel),
                      ),
                    ],
                  ),
                  if (order.decreaseCoins > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('积分抵扣', style: TextStyle(color: CupertinoColors.activeGreen)),
                        Text(
                          '-${currencyFormat.format(order.decreaseCoins / 100)}',
                          style: const TextStyle(color: CupertinoColors.activeGreen),
                        ),
                      ],
                    ),
                  ],
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('实付金额', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        currencyFormat.format(order.actualPayYuan),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: CupertinoColors.destructiveRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 操作按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (ctx) => CupertinoAlertDialog(
                            title: const Text('打印'),
                            content: const Text('正在调用打印机...'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('确定'),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.printer),
                          SizedBox(width: 8),
                          Text('打印小票'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: const Color(0xFF07C160),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        context.go('/home/retail/entry');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.cart_badge_plus, color: CupertinoColors.white),
                          SizedBox(width: 8),
                          Text('再来一单', style: TextStyle(color: CupertinoColors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        context.go('/home');
                      },
                      child: const Text(
                        '返回首页',
                        style: TextStyle(color: CupertinoColors.label),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPayMethodLabel(int method) {
    switch (method) {
      case 1:
        return '现金';
      case 2:
        return '微信';
      case 3:
        return '支付宝';
      case 4:
        return '银行卡';
      default:
        return '未知';
    }
  }
}