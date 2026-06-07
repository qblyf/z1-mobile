import 'package:flutter/cupertino.dart';

class TaskHomePage extends StatelessWidget {
  const TaskHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('任务'),
        previousPageTitle: '返回',
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _TaskSection(
              title: '今日任务',
              tasks: [
                _TaskItem(
                  title: '完成会员资料补充',
                  deadline: '今天 18:00',
                  priority: _TaskPriority.high,
                ),
                _TaskItem(
                  title: '跟进订单 #20240115001',
                  deadline: '今天 20:00',
                  priority: _TaskPriority.medium,
                ),
              ],
            ),
            SizedBox(height: 24),
            _TaskSection(
              title: '本周任务',
              tasks: [
                _TaskItem(
                  title: '周报提交',
                  deadline: '周五 17:00',
                  priority: _TaskPriority.medium,
                ),
                _TaskItem(
                  title: '库存盘点',
                  deadline: '周四 18:00',
                  priority: _TaskPriority.low,
                ),
              ],
            ),
            SizedBox(height: 24),
            _TaskSection(
              title: '已完成',
              tasks: [
                _TaskItem(
                  title: '客户回访',
                  deadline: '昨天',
                  priority: _TaskPriority.low,
                  isCompleted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _TaskPriority { high, medium, low }

class _TaskSection extends StatelessWidget {
  final String title;
  final List<_TaskItem> tasks;

  const _TaskSection({required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => _TaskCard(task: task)),
      ],
    );
  }
}

class _TaskItem {
  final String title;
  final String deadline;
  final _TaskPriority priority;
  final bool isCompleted;

  const _TaskItem({
    required this.title,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
  });
}

class _TaskCard extends StatelessWidget {
  final _TaskItem task;

  const _TaskCard({required this.task});

  Color get _priorityColor {
    switch (task.priority) {
      case _TaskPriority.high:
        return const Color(0xFFDC2626);
      case _TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case _TaskPriority.low:
        return const Color(0xFF10B981);
    }
  }

  IconData get _priorityIcon {
    switch (task.priority) {
      case _TaskPriority.high:
        return CupertinoIcons.exclamationmark_circle_fill;
      case _TaskPriority.medium:
        return CupertinoIcons.circle_fill;
      case _TaskPriority.low:
        return CupertinoIcons.minus_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? CupertinoColors.systemGrey4
              : _priorityColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            task.isCompleted
                ? CupertinoIcons.checkmark_circle_fill
                : _priorityIcon,
            color: task.isCompleted ? const Color(0xFF10B981) : _priorityColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? CupertinoColors.secondaryLabel
                        : CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.deadline,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (!task.isCompleted)
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.tertiaryLabel,
              size: 16,
            ),
        ],
      ),
    );
  }
}
