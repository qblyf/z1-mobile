// ============================================================
// 审批相关类型
// 从 z1-mid SDK approval-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 外部平台类型
// ============================================================

enum PlatformType {
  dingtalk('dingtalk'),
  weixin('weixin'),
  feishu('feishu'),
  s1('s1');

  final String value;
  const PlatformType(this.value);

  static PlatformType? fromValue(String? value) {
    if (value == null) return null;
    return PlatformType.values.cast<PlatformType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 审批状态
// ============================================================

enum ApprovalStatus {
  pending('to-audit'),   // 待审批
  rejected('rejected'),   // 已驳回
  approved('audited'),    // 已通过
  terminated('terminate'); // 已撤销

  final String value;
  const ApprovalStatus(this.value);

  static ApprovalStatus? fromValue(String? value) {
    if (value == null) return null;
    return ApprovalStatus.values.cast<ApprovalStatus?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 审批类型
// ============================================================

enum ApprovalType {
  lowValueAssetsPurchase('lowValueAssetsPurchase'),  // 易耗品采购
  lowValueAssetsApply('lowValueAssetsApply'),        // 易耗品申请
  standardToNonStandard('standardToNonStandard'),    // 标品转非标
  accountingVouchers('accountingVouchers'),          // 会计凭证
  discountLog('discountLog'),                        // 折扣记录
  financialExpenses('financialExpenses'),            // 财务支出
  financialExpensesSettle('financialExpensesSettle'), // 财务支出结算
  invoiceApply('invoiceApply'),                      // 发票申请
  lossReportApply('lossReportApply'),                // 报损单申请
  entryApply('entryApply'),                          // 入职申请
  priceChange('priceChange'),                        // 改价申请
  lowLimitPriceChange('lowLimitPriceChange'),       // 低于大盘价改价申请
  emplScoreApply('emplScoreApply'),                  // 工分申报单
  purchaseOrderApply('purchaseOrderApply');          // 采购订单申请

  final String value;
  const ApprovalType(this.value);

  static ApprovalType? fromValue(String? value) {
    if (value == null) return null;
    return ApprovalType.values.cast<ApprovalType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

// ============================================================
// 关联单据
// ============================================================

class ApprovalAssociated {
  final String? lowValueAssetsPurchaseNumber;
  final String? lowValueAssetsApplyNumber;
  final String? discountApprovalZID;
  final int? purchaseOrderID;

  ApprovalAssociated({
    this.lowValueAssetsPurchaseNumber,
    this.lowValueAssetsApplyNumber,
    this.discountApprovalZID,
    this.purchaseOrderID,
  });

  factory ApprovalAssociated.fromJson(Map<String, dynamic> json) {
    return ApprovalAssociated(
      lowValueAssetsPurchaseNumber: json['lowValueAssetsPurchaseNumber'] as String?,
      lowValueAssetsApplyNumber: json['lowValueAssetsApplyNumber'] as String?,
      discountApprovalZID: json['discountApprovalZID'] as String?,
      purchaseOrderID: json['purchaseOrderID'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lowValueAssetsPurchaseNumber': lowValueAssetsPurchaseNumber,
      'lowValueAssetsApplyNumber': lowValueAssetsApplyNumber,
      'discountApprovalZID': discountApprovalZID,
      'purchaseOrderID': purchaseOrderID,
    };
  }
}

// ============================================================
// 审批
// ============================================================

class Approval {
  final int id;
  final ApprovalType approvalType;
  final String approvalData;
  final ApprovalAssociated? associated;
  final PlatformType platform;
  final String instanceID;
  final ApprovalStatus status;
  final String? result;
  final UnixTimestamp createdAt;
  final UserIdent createdBy;
  final UnixTimestamp updatedAt;
  final UserIdent updatedBy;

  Approval({
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

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['id'] as int,
      approvalType: ApprovalType.fromValue(json['approvalType'] as String?) ?? ApprovalType.priceChange,
      approvalData: json['approvalData'] as String,
      associated: json['associated'] != null
          ? ApprovalAssociated.fromJson(json['associated'] as Map<String, dynamic>)
          : null,
      platform: PlatformType.fromValue(json['platform'] as String?) ?? PlatformType.feishu,
      instanceID: json['instanceID'] as String,
      status: ApprovalStatus.fromValue(json['status'] as String?) ?? ApprovalStatus.pending,
      result: json['result'] as String?,
      createdAt: json['createdAt'] as UnixTimestamp,
      createdBy: json['createdBy'] as UserIdent,
      updatedAt: json['updatedAt'] as UnixTimestamp,
      updatedBy: json['updatedBy'] as UserIdent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'approvalType': approvalType.value,
      'approvalData': approvalData,
      'associated': associated?.toJson(),
      'platform': platform.value,
      'instanceID': instanceID,
      'status': status.value,
      'result': result,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
}
