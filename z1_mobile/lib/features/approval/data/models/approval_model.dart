import 'package:equatable/equatable.dart';

enum ApprovalStatus {
  toAudit('to-audit', '待审批'),
  rejected('rejected', '已驳回'),
  audited('audited', '已通过'),
  terminate('terminate', '已终止');

  final String value;
  final String label;
  const ApprovalStatus(this.value, this.label);

  static ApprovalStatus fromString(String? status) {
    switch (status) {
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'audited':
        return ApprovalStatus.audited;
      case 'terminate':
        return ApprovalStatus.terminate;
      case 'to-audit':
      default:
        return ApprovalStatus.toAudit;
    }
  }
}

enum ApprovalType {
  lowValueAssetsPurchase('lowValueAssetsPurchase', '易耗品采购'),
  lowValueAssetsApply('lowValueAssetsApply', '易耗品申请'),
  standardToNonStandard('standardToNonStandard', '标品转非标'),
  accountingVouchers('accountingVouchers', '会计凭证'),
  discountLog('discountLog', '折扣记录'),
  financialExpenses('financialExpenses', '财务支出'),
  financialExpensesSettle('financialExpensesSettle', '财务支出结算'),
  invoiceApply('invoiceApply', '发票申请'),
  lossReportApply('lossReportApply', '报损单申请'),
  entryApply('entryApply', '入职申请'),
  priceChange('priceChange', '改价申请'),
  lowLimitPriceChange('lowLimitPriceChange', '低于大盘价改价'),
  emplScoreApply('emplScoreApply', '工分申报单'),
  purchaseOrderApply('purchaseOrderApply', '采购订单申请');

  final String value;
  final String label;
  const ApprovalType(this.value, this.label);

  static ApprovalType fromString(String? type) {
    for (final t in ApprovalType.values) {
      if (t.value == type) return t;
    }
    return ApprovalType.discountLog;
  }
}

enum PlatformType {
  dingtalk('dingtalk', '钉钉'),
  weixin('weixin', '企业微信'),
  feishu('feishu', '飞书'),
  s1('s1', 'S1审批');

  final String value;
  final String label;
  const PlatformType(this.value, this.label);

  static PlatformType fromString(String? platform) {
    switch (platform) {
      case 'weixin':
        return PlatformType.weixin;
      case 'feishu':
        return PlatformType.feishu;
      case 's1':
        return PlatformType.s1;
      case 'dingtalk':
      default:
        return PlatformType.dingtalk;
    }
  }
}

class ApprovalModel extends Equatable {
  final int id;
  final ApprovalType approvalType;
  final String approvalData;
  final Map<String, dynamic>? associated;
  final PlatformType platform;
  final String instanceID;
  final ApprovalStatus status;
  final String? result;
  final int createdAt;
  final int createdBy;
  final int updatedAt;
  final int updatedBy;

  const ApprovalModel({
    required this.id,
    required this.approvalType,
    required this.approvalData,
    this.associated,
    required this.platform,
    required this.instanceID,
    required this.status,
    this.result,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      id: json['id'] as int? ?? 0,
      approvalType: ApprovalType.fromString(json['approvalType'] as String?),
      approvalData: json['approvalData'] as String? ?? '{}',
      associated: json['associated'] as Map<String, dynamic>?,
      platform: PlatformType.fromString(json['platform'] as String?),
      instanceID: json['instanceID'] as String? ?? '',
      status: ApprovalStatus.fromString(json['status'] as String?),
      result: json['result'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
      updatedBy: json['updatedBy'] as int? ?? 0,
    );
  }

  String get typeLabel => approvalType.label;

  String get statusLabel => status.label;

  String get timeAgo {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - createdAt;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return '${diff ~/ 60}分钟前';
    if (diff < 86400) return '${diff ~/ 3600}小时前';
    return '${diff ~/ 86400}天前';
  }

  String? get relatedOrderNumber {
    if (associated == null) return null;
    return associated!['orderNumber'] as String?;
  }

  int? get amount {
    try {
      final data = _parseApprovalData();
      if (data == null) return null;
      if (data.containsKey('amount')) {
        return data['amount'] as int? ?? 0;
      }
      if (data.containsKey('discountAmount')) {
        return data['discountAmount'] as int? ?? 0;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _parseApprovalData() {
    try {
      return {} as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [id, instanceID, status, createdAt];
}