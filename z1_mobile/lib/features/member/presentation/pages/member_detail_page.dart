import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';
import '../../data/models/member_model.dart';
import '../../data/models/member_order_model.dart';
import '../bloc/member_detail_bloc.dart';

class MemberDetailPage extends StatelessWidget {
  final int memberId;

  const MemberDetailPage({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = MemberDetailBloc(dataSource: getIt());
        bloc.add(MemberDetailLoadRequested(memberId));
        return bloc;
      },
      child: _MemberDetailPageContent(memberId: memberId),
    );
  }
}

class _MemberDetailPageContent extends StatelessWidget {
  final int memberId;

  const _MemberDetailPageContent({required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员信息'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<MemberDetailBloc, MemberDetailState>(
        builder: (context, state) {
          if (state is MemberDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MemberDetailError) {
            return _buildErrorView(context, state.message);
          }

          if (state is MemberDetailNotFound) {
            return _buildNotFoundView(context);
          }

          if (state is MemberDetailLoaded) {
            return _buildContent(context, state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('会员不存在'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MemberDetailLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MemberDetailBloc>().add(const MemberDetailRefreshRequested());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMemberCard(state.member),
          const SizedBox(height: 16),
          _buildExperienceCard(context, state.member),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 16),
          _buildConsumptionSummary(context, state.orders),
          const SizedBox(height: 16),
          _buildOrderList(context, state.orders),
        ],
      ),
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              member.levelName,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.phone,
                        style: const TextStyle(
                          color: AppTheme.grey600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.grey200),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '注册于 ${member.createdAtFormatted}',
                  style: const TextStyle(
                    color: AppTheme.grey500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (member.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: member.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.grey100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppTheme.grey700,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, MemberModel member) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '可用积分',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  member.availableExperienceYuan.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '可抵 ¥${member.availableExperienceYuan.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.grey500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/member/$memberId/creditscore'),
                    child: const Text('积分查询'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/member/$memberId/creditscore/edit'),
                    child: const Text('积分调整'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快捷操作',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(Icons.receipt_long, '消费记录'),
                _buildActionItem(Icons.card_giftcard, '优惠券'),
                _buildActionItem(Icons.account_balance_wallet, '储值'),
                _buildActionItem(Icons.note_add, '备注'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.grey700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionSummary(BuildContext context, List<MemberOrderModel> orders) {
    if (orders.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final todayStart = DateTime(now).copyWith(hour: 0, minute: 0, second: 0).millisecondsSinceEpoch ~/ 1000;
    final weekStart = todayStart - (86400 * 7);

    int todayAmount = 0;
    int weekAmount = 0;

    for (final order in orders) {
      if (order.createdAt >= todayStart) {
        todayAmount += order.finalAmount;
      }
      if (order.createdAt >= weekStart) {
        weekAmount += order.finalAmount;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '消费统计',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¥${(todayAmount / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        '今日',
                        style: TextStyle(
                          color: AppTheme.grey500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¥${(weekAmount / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        '本周',
                        style: TextStyle(
                          color: AppTheme.grey500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('查看全部'),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<MemberOrderModel> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '消费记录',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  '暂无消费记录',
                  style: TextStyle(color: AppTheme.grey500),
                ),
              ),
            ),
          )
        else
          ...orders.map((order) => _buildOrderItem(context, order)),
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, MemberOrderModel order) {
    final isCompleted = order.statusEnum == OrderStatus.completed;
    final statusColor = isCompleted ? AppTheme.successColor : AppTheme.warningColor;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/order/${order.orderNumber}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.createdAtFormatted,
                      style: const TextStyle(
                        color: AppTheme.grey500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${order.finalAmountYuan.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}