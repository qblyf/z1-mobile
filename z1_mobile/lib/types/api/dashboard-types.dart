// ============================================================
// 仪表盘相关类型
// 基于 home-detail-prd.md, workbench-detail-prd.md 文档
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 今日统计数据
// ============================================================

class TodayStat {
  final int todaySales;
  final int todayOrderCount;
  final int? todayCompletedCount;
  final int? yesterdaySales;
  final double? changeRate;

  TodayStat({
    required this.todaySales,
    required this.todayOrderCount,
    this.todayCompletedCount,
    this.yesterdaySales,
    this.changeRate,
  });

  factory TodayStat.fromJson(Map<String, dynamic> json) {
    return TodayStat(
      todaySales: json['todaySales'] as int? ?? 0,
      todayOrderCount: json['todayOrderCount'] as int? ?? 0,
      todayCompletedCount: json['todayCompletedCount'] as int?,
      yesterdaySales: json['yesterdaySales'] as int?,
      changeRate: (json['changeRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todaySales': todaySales,
      'todayOrderCount': todayOrderCount,
      'todayCompletedCount': todayCompletedCount,
      'yesterdaySales': yesterdaySales,
      'changeRate': changeRate,
    };
  }
}

// ============================================================
// 待办任务摘要
// ============================================================

class TaskSummary {
  final int taskId;
  final String title;
  final String? content;
  final String status;
  final String priority;
  final UnixTimestamp? dueTime;
  final UnixTimestamp createdAt;

  TaskSummary({
    required this.taskId,
    required this.title,
    this.content,
    required this.status,
    required this.priority,
    this.dueTime,
    required this.createdAt,
  });

  factory TaskSummary.fromJson(Map<String, dynamic> json) {
    return TaskSummary(
      taskId: json['taskId'] as int? ?? json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'normal',
      dueTime: json['dueTime'] as UnixTimestamp?,
      createdAt: json['createdAt'] as UnixTimestamp? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'title': title,
      'content': content,
      'status': status,
      'priority': priority,
      'dueTime': dueTime,
      'createdAt': createdAt,
    };
  }
}
