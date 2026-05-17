import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// 优惠券选择页 - 占位符
/// TODO: 联调 GET /coupons/self 接口，获取可用优惠券列表
class CouponSelectPage extends StatelessWidget {
  const CouponSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 解析 extra（可选，如果需要回调）
    final extra = GoRouter.of(context).routerDelegate.currentConfiguration.extra as Map<String, dynamic>?;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('选择优惠券'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('取消'),
          onPressed: () => context.pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('确定'),
          onPressed: () {
            // TODO: 返回选中的优惠券数量和金额
            context.pop();
          },
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.ticket,
                size: 64,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                '优惠券选择页',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'TODO: 联调 GET /coupons/self 接口',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () {
                  // 测试：模拟选择1张券
                  context.pop({'couponCount': 1, 'discount': 1000}); // discount 单位：分
                },
                child: const Text('模拟选择 1 张券（抵 ¥10）'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}