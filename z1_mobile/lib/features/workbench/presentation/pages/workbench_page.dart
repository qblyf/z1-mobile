import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// 工作台页面
class WorkbenchPage extends StatelessWidget {
  const WorkbenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('💼 工作台'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 快捷操作
            _buildQuickActions(context),
            const SizedBox(height: 16),

            // 待办审批
            _buildPendingApprovals(),
            const SizedBox(height: 16),

            // 今日任务
            _buildTodayTasks(),
            const SizedBox(height: 16),

            // 消息通知
            _buildNotifications(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '🚀 快捷操作',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionItem(icon: CupertinoIcons.cart, label: '零售开单', color: const Color(0xFFFF6B35), onTap: () => context.go('/order/retail/entry')),
            _QuickActionItem(icon: CupertinoIcons.barcode_viewfinder, label: '扫码', color: CupertinoColors.activeGreen),
            _QuickActionItem(icon: CupertinoIcons.search, label: '查序列号', color: CupertinoColors.activeBlue),
            _QuickActionItem(icon: CupertinoIcons.person_2, label: '查会员', color: const Color(0xFFAF52DE)),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingApprovals() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '待办审批',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _ApprovalItem(
            icon: '📋',
            title: '退换货审批',
            subtitle: '订单 Z1-20260514-028 · ¥560',
            tag: '紧急',
            tagColor: CupertinoColors.destructiveRed,
          ),
          _ApprovalItem(
            icon: '📦',
            title: '调拨确认',
            subtitle: '从华强北二店调入 12 件商品',
            time: '2小时前',
          ),
          _ApprovalItem(
            icon: '💰',
            title: '积分调整审批',
            subtitle: '会员张三 · 调整积分 2000',
            time: '5小时前',
            showBorder: false,
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text(
                '查看全部审批 >',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasks() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBF0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '今日任务',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const Text(
                  '3 项待完成',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _TaskItem(
            icon: '📦',
            title: '盘点珠宝区',
            subtitle: '截止时间 18:00',
            tag: '紧急',
            tagColor: CupertinoColors.destructiveRed,
          ),
          _TaskItem(
            icon: '📝',
            title: '周报填写',
            subtitle: '截止时间 明天 09:00',
            time: '明天',
          ),
          _TaskItem(
            icon: '📞',
            title: '客户回访',
            subtitle: 'VIP 客户：赵总 · 购买钻戒',
            time: '本周',
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('📢', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '消息通知',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _NotificationItem(
            title: '系统更新通知',
            content: 'Z1 全网连锁 v2.3.0 版本已发布...',
            time: '刚刚',
          ),
          _NotificationItem(
            title: '库存预警',
            content: '商品「50分钻戒 D色 VS1」库存不足...',
            time: '1小时前',
          ),
          _NotificationItem(
            title: '审批提醒',
            content: '您有 3 条待审批事项，请及时处理',
            time: '3小时前',
            showBorder: false,
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? tag;
  final Color? tagColor;
  final String? time;
  final bool showBorder;

  const _ApprovalItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    this.tagColor,
    this.time,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12),
                ),
              ],
            ),
          ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag!,
                style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          if (time != null && tag == null)
            Text(
              time!,
              style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? tag;
  final Color? tagColor;
  final String? time;
  final bool showBorder;

  const _TaskItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    this.tagColor,
    this.time,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12),
                ),
              ],
            ),
          ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag!,
                style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          if (time != null && tag == null)
            Text(
              time!,
              style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String content;
  final String time;
  final bool showBorder;

  const _NotificationItem({
    required this.title,
    required this.content,
    required this.time,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
              Text(
                time,
                style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12),
          ),
        ],
      ),
    );
  }
}