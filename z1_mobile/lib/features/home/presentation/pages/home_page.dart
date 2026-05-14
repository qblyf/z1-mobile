import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// 首页 - iOS 风格
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Z1 全网连锁'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.power),
          onPressed: () => _showLogoutDialog(context),
        ),
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            AppRouter.goLogin(context);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 欢迎信息
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final userName = state.user?.name ?? '用户';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '欢迎回来，$userName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '门店: ${state.user?.shopName ?? '未选择'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel.resolveFrom(context),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 功能菜单
                const Text(
                  '功能菜单',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // 菜单网格
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _MenuCard(
                        icon: CupertinoIcons.cart,
                        title: '零售开单',
                        color: CupertinoColors.activeBlue,
                        onTap: () {},
                      ),
                      _MenuCard(
                        icon: CupertinoIcons.doc_text,
                        title: '订单列表',
                        color: CupertinoColors.activeGreen,
                        onTap: () {},
                      ),
                      _MenuCard(
                        icon: CupertinoIcons.cube_box,
                        title: '库存管理',
                        color: CupertinoColors.activeOrange,
                        onTap: () {},
                      ),
                      _MenuCard(
                        icon: CupertinoIcons.person_2,
                        title: '会员中心',
                        color: CupertinoColors.systemPurple,
                        onTap: () {},
                      ),
                      _MenuCard(
                        icon: CupertinoIcons.calendar,
                        title: '行事历',
                        color: CupertinoColors.systemGreen,
                        onTap: () {},
                      ),
                      _MenuCard(
                        icon: CupertinoIcons.checkmark_seal,
                        title: '审批中心',
                        color: CupertinoColors.destructiveRed,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('确定'),
          ),
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}

/// 菜单卡片 - iOS 风格
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
BoxShadow(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}