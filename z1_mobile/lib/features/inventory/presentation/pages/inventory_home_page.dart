import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class InventoryHomePage extends StatelessWidget {
  const InventoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('库存管理'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _MenuCard(
                icon: CupertinoIcons.cube_box,
                label: '盘库',
                color: CupertinoColors.activeBlue,
                onTap: () => context.go('/inventory/stocktaking'),
              ),
              _MenuCard(
                icon: CupertinoIcons.arrow_right_arrow_left,
                label: '调拨',
                color: CupertinoColors.activeGreen,
                onTap: () => context.go('/inventory/transfer'),
              ),
              _MenuCard(
                icon: CupertinoIcons.cart,
                label: '采购',
                color: CupertinoColors.activeOrange,
                onTap: () => context.go('/inventory/purchase-list'),
              ),
              _MenuCard(
                icon: CupertinoIcons.barcode,
                label: '序列号查询',
                color: const Color(0xFFAF52DE),
                onTap: () => context.go('/inventory/serial-search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
