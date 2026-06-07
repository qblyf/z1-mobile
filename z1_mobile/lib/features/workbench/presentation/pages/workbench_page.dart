import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/workbench_models.dart';
import '../bloc/workbench_bloc.dart';

/// 工作台页面
class WorkbenchPage extends StatelessWidget {
  const WorkbenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('💼 工作台'),
        trailing: BlocBuilder<WorkbenchBloc, WorkbenchState>(
          buildWhen: (prev, curr) {
            if (prev is WorkbenchLoaded && curr is WorkbenchLoaded) {
              return prev.stats.unreadNotificationCount !=
                  curr.stats.unreadNotificationCount;
            }
            return curr is WorkbenchLoaded;
          },
          builder: (ctx, state) {
            final count = state is WorkbenchLoaded
                ? state.stats.unreadNotificationCount
                : 0;
            return GestureDetector(
              onTap: () => ctx.push('/notification'),
              child: count > 0
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(CupertinoIcons.bell,
                            color: CupertinoColors.activeBlue),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: CupertinoColors.destructiveRed,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              count > 9 ? '9+' : count.toString(),
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Icon(CupertinoIcons.bell,
                      color: CupertinoColors.activeBlue),
            );
          },
        ),
      ),
      child: BlocBuilder<WorkbenchBloc, WorkbenchState>(
        builder: (context, state) {
          if (state is WorkbenchLoading || state is WorkbenchInitial) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is WorkbenchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(
                          color: CupertinoColors.secondaryLabel)),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () => context
                        .read<WorkbenchBloc>()
                        .add(const WorkbenchLoadRequested()),
                    child: const Text('重新加载'),
                  ),
                ],
              ),
            );
          }

          final loaded = state as WorkbenchLoaded;
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  context
                      .read<WorkbenchBloc>()
                      .add(const WorkbenchRefreshRequested());
                  await Future.delayed(const Duration(milliseconds: 800));
                },
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _QuickActionsSection(),
                    const SizedBox(height: 16),
                    _TodaySummarySection(stats: loaded.stats),
                    const SizedBox(height: 16),
                    _PendingApprovalsSection(
                      approvals: loaded.pendingApprovals,
                      count: loaded.stats.pendingApprovalCount,
                    ),
                    const SizedBox(height: 16),
                    _TodayTasksSection(tasks: loaded.pendingTasks),
                    const SizedBox(height: 16),
                    _NotificationsSection(
                        unreadCount: loaded.stats.unreadNotificationCount),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 快捷操作区
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            _QuickActionItem(
              icon: CupertinoIcons.cart,
              label: '零售开单',
              color: const Color(0xFFFF6B35),
              onTap: () => context.go('/home/retail/entry'),
            ),
            const _QuickActionItem(
              icon: CupertinoIcons.barcode_viewfinder,
              label: '扫码',
              color: CupertinoColors.activeGreen,
            ),
            _QuickActionItem(
              icon: CupertinoIcons.search,
              label: '查序列号',
              color: CupertinoColors.activeBlue,
              onTap: () => context.go('/inventory/serial-search'),
            ),
            _QuickActionItem(
              icon: CupertinoIcons.person_2,
              label: '查会员',
              color: const Color(0xFFAF52DE),
              onTap: () => context.go('/member'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 今日概览区
class _TodaySummarySection extends StatelessWidget {
  final WorkbenchStats stats;
  const _TodaySummarySection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.month}月${now.day}日 周${_weekdayName(now.weekday)}';
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(dateStr,
                  style: const TextStyle(
                      fontSize: 13, color: CupertinoColors.secondaryLabel)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: '今日销售',
                  value:
                      '¥${(stats.todayStat.todaySales / 100).toStringAsFixed(2)}',
                  color: const Color(0xFFFF6B35),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: '订单数',
                  value: '${stats.todayStat.todayOrderCount}',
                  color: CupertinoColors.activeGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: '待处理审批',
                  value: '${stats.pendingApprovalCount}',
                  color: CupertinoColors.activeBlue,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: '待办任务',
                  value: '${stats.pendingTaskCount}',
                  color: const Color(0xFFAF52DE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return names[weekday - 1];
  }
}

/// 待办审批区
class _PendingApprovalsSection extends StatelessWidget {
  final List<WorkbenchApprovalItem> approvals;
  final int count;
  const _PendingApprovalsSection(
      {required this.approvals, required this.count});

  @override
  Widget build(BuildContext context) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: count > 0
                        ? CupertinoColors.destructiveRed
                        : CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (approvals.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '暂无待处理审批',
                style: TextStyle(
                    color: CupertinoColors.secondaryLabel, fontSize: 13),
              ),
            )
          else
            ...approvals.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _ApprovalItem(
                icon: _approvalTypeEmoji(item.approvalType.name),
                title: item.typeName,
                subtitle: item.summary,
                timeText: item.timeAgo,
                showBorder: index < approvals.length - 1,
                onTap: () => context.push('/approval/${item.id}'),
              );
            }),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => context.push('/approval/center'),
              child: const Text(
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

  String _approvalTypeEmoji(String type) {
    switch (type) {
      case 'transfer':
        return '🚚';
      case 'return':
        return '📦';
      case 'priceChange':
      case 'lowLimitPriceChange':
        return '💰';
      default:
        return '📋';
    }
  }
}

/// 今日任务区
class _TodayTasksSection extends StatelessWidget {
  final List<WorkbenchTaskItem> tasks;
  const _TodayTasksSection({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => !t.completed).length;
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
                Text(
                  '$pending 项待完成',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '暂无待办任务',
                style: TextStyle(
                    color: CupertinoColors.secondaryLabel, fontSize: 13),
              ),
            )
          else
            ...tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _TaskItem(
                icon: item.completed ? '✅' : '⬜',
                title: item.title,
                subtitle: item.planTime ?? '',
                tag: item.priority.label,
                tagColor: _priorityColor(item.priority),
                showBorder: index < tasks.length - 1,
                onTap: () => context.push('/task/${item.id}'),
              );
            }),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => context.push('/task/list'),
              child: const Text(
                '查看全部任务 >',
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

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return CupertinoColors.destructiveRed;
      case TaskPriority.medium:
        return const Color(0xFFFF9500);
      case TaskPriority.low:
        return CupertinoColors.activeGreen;
    }
  }
}

/// 消息通知区（mock，接口暂不存在）
class _NotificationsSection extends StatelessWidget {
  final int unreadCount;
  const _NotificationsSection({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: unreadCount > 0
                        ? CupertinoColors.destructiveRed
                        : CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _NotificationItem(
            title: '系统更新通知',
            content: 'Z1 全网连锁 v2.3.0 版本已发布...',
            time: '刚刚',
          ),
          const _NotificationItem(
            title: '库存预警',
            content: '商品「50分钻戒 D色 VS1」库存不足...',
            time: '1小时前',
          ),
          const _NotificationItem(
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

// ============ 通用 Widget ============

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: CupertinoColors.secondaryLabel)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            )),
      ],
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? timeText;
  final bool showBorder;
  final VoidCallback? onTap;

  const _ApprovalItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.timeText,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(
                  bottom:
                      BorderSide(color: CupertinoColors.separator, width: 0.5),
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
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: CupertinoColors.secondaryLabel, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (timeText != null)
              Text(
                timeText!,
                style: const TextStyle(
                    color: CupertinoColors.secondaryLabel, fontSize: 11),
              ),
          ],
        ),
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
  final bool showBorder;
  final VoidCallback? onTap;

  const _TaskItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    this.tagColor,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(
                  bottom:
                      BorderSide(color: CupertinoColors.separator, width: 0.5),
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
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: CupertinoColors.secondaryLabel, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor?.withValues(alpha: 0.1) ??
                      CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag!,
                  style: TextStyle(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
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
                bottom:
                    BorderSide(color: CupertinoColors.separator, width: 0.5),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14))),
              Text(
                time,
                style: const TextStyle(
                    color: CupertinoColors.secondaryLabel, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
                color: CupertinoColors.secondaryLabel, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
