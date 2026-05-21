import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/approval_remote_datasource.dart';
import '../../data/models/approval_model.dart';
import '../bloc/approval_list_bloc.dart';

class ApprovalCenterPage extends StatelessWidget {
  const ApprovalCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApprovalListBloc(
        dataSource: ApprovalRemoteDataSourceImpl(
          apiClient: _.read(),
        ),
      )..add(const ApprovalListLoadRequested()),
      child: const _ApprovalCenterView(),
    );
  }
}

class _ApprovalCenterView extends StatefulWidget {
  const _ApprovalCenterView();

  @override
  State<_ApprovalCenterView> createState() => _ApprovalCenterViewState();
}

class _ApprovalCenterViewState extends State<_ApprovalCenterView> {
  ApprovalTab _currentTab = ApprovalTab.all;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('审批中心'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: BlocBuilder<ApprovalListBloc, ApprovalListState>(
                builder: (context, state) {
                  if (state is ApprovalListLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (state is ApprovalListError) {
                    return _buildError(state.message);
                  }
                  if (state is ApprovalListLoaded || state is ApprovalListLoadingMore) {
                    final approvals = state is ApprovalListLoaded
                        ? state.approvals
                        : (state as ApprovalListLoadingMore).approvals;
                    if (approvals.isEmpty) {
                      return _buildEmpty();
                    }
                    return _buildList(approvals, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem('全部', ApprovalTab.all),
          _buildTabItem('待审批', ApprovalTab.toAudit),
          _buildTabItem('已通过', ApprovalTab.audited),
          _buildTabItem('已驳回', ApprovalTab.rejected),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, ApprovalTab tab) {
    final isSelected = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentTab = tab);
          context.read<ApprovalListBloc>().add(ApprovalListTabChanged(tab));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemBackground,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<ApprovalModel> approvals, ApprovalListState state) {
    final hasReachedMax = state is ApprovalListLoaded ? state.hasReachedMax : false;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            !hasReachedMax) {
          context.read<ApprovalListBloc>().add(const ApprovalListLoadMoreRequested());
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              context.read<ApprovalListBloc>().add(const ApprovalListRefreshRequested());
            },
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= approvals.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                return _ApprovalListItem(approval: approvals[index]);
              },
              childCount: approvals.length + (hasReachedMax ? 0 : 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            '暂无审批记录',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: CupertinoColors.secondaryLabel)),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: () {
              context.read<ApprovalListBloc>().add(const ApprovalListLoadRequested());
            },
            child: const Text('点击重试'),
          ),
        ],
      ),
    );
  }
}

class _ApprovalListItem extends StatelessWidget {
  final ApprovalModel approval;

  const _ApprovalListItem({required this.approval});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(approval.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  approval.typeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(approval.status),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                approval.timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (approval.relatedOrderNumber != null) ...[
            Text(
              '关联订单：${approval.relatedOrderNumber}',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (approval.amount != null)
            Text(
              '申请金额：¥${(approval.amount! / 100).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPlatformBadge(),
              const Spacer(),
              Text(
                approval.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(approval.status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        approval.platform.label,
        style: const TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel),
      ),
    );
  }

  Color _getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.toAudit:
        return CupertinoColors.destructiveRed;
      case ApprovalStatus.audited:
        return CupertinoColors.activeGreen;
      case ApprovalStatus.rejected:
      case ApprovalStatus.terminate:
        return CupertinoColors.systemGrey;
    }
  }
}