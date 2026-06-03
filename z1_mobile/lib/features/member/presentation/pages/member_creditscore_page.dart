import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar;
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/result.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';
import '../../data/models/member_model.dart';

class MemberCreditscorePage extends StatefulWidget {
  final int memberId;

  const MemberCreditscorePage({super.key, required this.memberId});

  @override
  State<MemberCreditscorePage> createState() => _MemberCreditscorePageState();
}

class _MemberCreditscorePageState extends State<MemberCreditscorePage> {
  MemberCreditscoreState _state = MemberCreditscoreLoading();
  MemberModel? _member;
  List<CreditRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _state = MemberCreditscoreLoading());
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get(ApiEndpoints.memberCreditscore, queryParameters: {'userIdents': widget.memberId});
      if (response is Success && response.value != null) {
        final data = response.value as Map<String, dynamic>;
        _member = MemberModel.fromJson(data['member'] ?? {});
        final recordsList = (data['records'] as List?)?.map((e) => CreditRecord.fromJson(e as Map<String, dynamic>)).toList() ?? [];
        setState(() {
          _member = _member;
          _records = recordsList;
          _state = MemberCreditscoreLoaded();
        });
      } else {
        setState(() => _state = MemberCreditscoreError('加载失败'));
      }
    } catch (e) {
      setState(() => _state = MemberCreditscoreError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('积分查询'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_state is MemberCreditscoreLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_state is MemberCreditscoreError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((_state as MemberCreditscoreError).message, style: const TextStyle(color: AppTheme.grey600)),
            const SizedBox(height: 16),
            CupertinoButton.filled(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_member != null) _buildMemberCard(_member!),
        const SizedBox(height: 16),
        _buildRecordsList(),
      ],
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: CupertinoColors.systemGrey.withValues(alpha: 0.1), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  member.name.isNotEmpty ? member.name[0] : '?',
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(member.phone, style: const TextStyle(color: AppTheme.grey500, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text('当前积分', style: TextStyle(color: AppTheme.grey600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '${member.availableExperience}',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 32),
                    ),
                    Text(
                      '可抵 ¥${member.availableExperienceYuan.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppTheme.grey500, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('积分变动记录', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        if (_records.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('暂无变动记录', style: TextStyle(color: AppTheme.grey500))),
          )
        else
          ..._records.map((record) => _buildRecordItem(record)),
      ],
    );
  }

  Widget _buildRecordItem(CreditRecord record) {
    final isPositive = record.change > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isPositive ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPositive ? CupertinoIcons.add : CupertinoIcons.minus,
              color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.typeLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  record.createdAtFormatted,
                  style: const TextStyle(color: AppTheme.grey500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${record.change}',
                style: TextStyle(
                  color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (record.note?.isNotEmpty ?? false)
                Text(
                  record.note!,
                  style: const TextStyle(color: AppTheme.grey500, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreditRecord {
  final int id;
  final String type;
  final String typeLabel;
  final int change;
  final String? note;
  final int createdAt;

  CreditRecord({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.change,
    this.note,
    required this.createdAt,
  });

  factory CreditRecord.fromJson(Map<String, dynamic> json) => CreditRecord(
        id: json['id'] as int? ?? 0,
        type: json['type'] as String? ?? '',
        typeLabel: json['typeLabel'] as String? ?? json['type'] as String? ?? '',
        change: json['change'] as int? ?? 0,
        note: json['note'] as String?,
        createdAt: json['createdAt'] as int? ?? 0,
      );

  String get createdAtFormatted {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

sealed class MemberCreditscoreState {}
class MemberCreditscoreLoading extends MemberCreditscoreState {}
class MemberCreditscoreLoaded extends MemberCreditscoreState {}
class MemberCreditscoreError extends MemberCreditscoreState {
  final String message;
  MemberCreditscoreError(this.message);
}