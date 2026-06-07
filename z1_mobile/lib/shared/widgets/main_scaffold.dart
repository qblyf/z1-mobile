import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// 主页面脚手架 - 包含底部导航栏
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/member')) return 1;
    if (location.startsWith('/workbench')) return 2;
    if (location.startsWith('/task')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/member');
        break;
      case 2:
        context.go('/workbench');
        break;
      case 3:
        context.go('/task');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: child),
          Container(
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBackground,
              border: Border(
                top: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: CupertinoTabBar(
                currentIndex: selectedIndex,
                onTap: (index) => _onTap(context, index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.home),
                    label: '首页',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person_2),
                    label: '会员',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.briefcase),
                    label: '工作台',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.list_bullet),
                    label: '任务',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person),
                    label: '我的',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}