import 'package:equatable/equatable.dart';
import 'package:z1_mobile/types/api/approval-types.dart';
import 'package:z1_mobile/types/api/dashboard-types.dart';

/// 工作台统计数据
class WorkbenchStats extends Equatable {
  final TodayStat todayStat;
  final int pendingApprovalCount;
  final int pendingTaskCount;
  final int unreadNotificationCount;

  const WorkbenchStats({
    required this.todayStat,
    required this.pendingApprovalCount,
    required this.pendingTaskCount,
    this.unreadNotificationCount = 0,
  });

  factory WorkbenchStats.empty() {
    return WorkbenchStats(
      todayStat: TodayStat(
        todaySales: 0,
        todayOrderCount: 0,
      ),
      pendingApprovalCount: 0,
      pendingTaskCount: 0,
    );
  }

  @override
  List<Object?> get props => [
        todayStat,
        pendingApprovalCount,
        pendingTaskCount,
        unreadNotificationCount,
      ];
}

/// 待审批项（用于工作台展示）
class WorkbenchApprovalItem extends Equatable {
  final int id;
  final ApprovalType approvalType;
  final String summary;
  final String applicantName;
  final int createdAt;

  const WorkbenchApprovalItem({
    required this.id,
    required this.approvalType,
    required this.summary,
    required this.applicantName,
    required this.createdAt,
  });

  factory WorkbenchApprovalItem.fromJson(Map<String, dynamic> json) {
    final approvalTypeStr = json['approvalType'] as String?;
    ApprovalType approvalType;
    
    if (approvalTypeStr == 'transfer') {
      approvalType = ApprovalType.purchaseOrderApply;
    } else {
      approvalType = ApprovalType.fromValue(approvalTypeStr) ?? ApprovalType.priceChange;
    }
    
    return WorkbenchApprovalItem(
      id: json['id'] as int? ?? 0,
      approvalType: approvalType,
      summary: json['summary'] as String? ?? '',
      applicantName: json['applicantName'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  String get typeName {
    switch (approvalType) {
      case ApprovalType.lowValueAssetsPurchase:
        return '易耗品采购';
      case ApprovalType.lowValueAssetsApply:
        return '易耗品申请';
      case ApprovalType.standardToNonStandard:
        return '标品转非标';
      case ApprovalType.accountingVouchers:
        return '会计凭证';
      case ApprovalType.discountLog:
        return '折扣记录';
      case ApprovalType.financialExpenses:
        return '财务支出';
      case ApprovalType.financialExpensesSettle:
        return '财务支出结算';
      case ApprovalType.invoiceApply:
        return '发票申请';
      case ApprovalType.lossReportApply:
        return '报损单申请';
      case ApprovalType.entryApply:
        return '入职申请';
      case ApprovalType.priceChange:
        return '改价申请';
      case ApprovalType.lowLimitPriceChange:
        return '低于大盘价改价';
      case ApprovalType.emplScoreApply:
        return '工分申报单';
      case ApprovalType.purchaseOrderApply:
        return '采购订单申请';
    }
  }

  String get timeAgo {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - createdAt;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return '${diff ~/ 60}分钟前';
    if (diff < 86400) return '${diff ~/ 3600}小时前';
    return '${diff ~/ 86400}天前';
  }

  @override
  List<Object?> get props => [id, approvalType, summary, applicantName, createdAt];
}

/// 待办任务项（用于工作台展示）
class WorkbenchTaskItem extends Equatable {
  final int id;
  final String title;
  final bool completed;
  final String? planTime;
  final TaskPriority priority;

  const WorkbenchTaskItem({
    required this.id,
    required this.title,
    required this.completed,
    this.planTime,
    this.priority = TaskPriority.medium,
  });

  factory WorkbenchTaskItem.fromJson(Map<String, dynamic> json) {
    return WorkbenchTaskItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      planTime: json['planTime'] as String?,
      priority: TaskPriority.fromValue(json['priority'] as String?),
    );
  }

  @override
  List<Object?> get props => [id, title, completed, planTime, priority];
}

/// 任务优先级
enum TaskPriority {
  low('low', '低'),
  medium('medium', '中'),
  high('high', '高');

  final String value;
  final String label;
  const TaskPriority(this.value, this.label);

  static TaskPriority fromValue(String? value) {
    if (value == null) return TaskPriority.medium;
    return TaskPriority.values.cast<TaskPriority?>().firstWhere(
          (e) => e?.value == value,
          orElse: () => TaskPriority.medium,
        ) ?? TaskPriority.medium;
  }
}