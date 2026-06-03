import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../injection.dart';
import '../../data/datasources/mall_order_remote_datasource.dart';
import '../../data/models/mall_order_model.dart';
import '../../../../types/api/mall-order-types.dart';
import '../bloc/mall_order_list_bloc.dart';
import '../utils.dart';

/// 商城订单列表页（PRD：6 个状态 tab，分页）
class MallOrderListPage extends StatefulWidget {
  const MallOrderListPage({super.key});

  @override
  State<MallOrderListPage> createState() => _MallOrderListPageState();
}

class _MallOrderListPageState extends State<MallOrderListPage> {
  late final ScrollController _scrollController;
  late final MallOrderListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _bloc = MallOrderListBloc(
      dataSource: MallOrderRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(const MallOrderListLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (offset >= max * 0.9) {
      _bloc.add(const MallOrderListLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('商城订单')),
        child: SafeArea(
          child: Column(
            children: [
              _buildTabBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<MallOrderListBloc, MallOrderListState>(
      buildWhen: (prev, curr) => _tabOf(prev) != _tabOf(curr),
      builder: (context, state) {
        final selected = _tabOf(state);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final tab in MallOrderDisplayStatus.values) ...[
                  _FilterTab(
                    label: tab.label,
                    isSelected: tab == selected,
                    onTap: () => _bloc.add(MallOrderListTabChanged(tab)),
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<MallOrderListBloc, MallOrderListState>(
      builder: (context, state) {
        if (state is MallOrderListInitial || state is MallOrderListLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (state is MallOrderListError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => _bloc.add(const MallOrderListRefreshRequested()),
          );
        }

        final orders = state is MallOrderListLoaded
            ? state.orders
            : (state as MallOrderListLoadingMore).orders;
        final isLoadingMore = state is MallOrderListLoadingMore;

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              '暂无商城订单',
              style: TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          );
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                _bloc.add(const MallOrderListRefreshRequested());
                await Future.delayed(const Duration(milliseconds: 500));
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= orders.length) {
                      return isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child:
                                  Center(child: CupertinoActivityIndicator()),
                            )
                          : const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MallOrderCard(order: orders[index]),
                    );
                  },
                  childCount: orders.length + (isLoadingMore ? 1 : 0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  MallOrderDisplayStatus _tabOf(MallOrderListState s) {
    if (s is MallOrderListLoaded) return s.tab;
    if (s is MallOrderListLoadingMore) return s.tab;
    if (s is MallOrderListLoading) return s.tab;
    if (s is MallOrderListError) return s.tab;
    return MallOrderDisplayStatus.all;
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.separator,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color:
                isSelected ? CupertinoColors.white : CupertinoColors.label,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: CupertinoColors.secondaryLabel),
          ),
          const SizedBox(height: 16),
          CupertinoButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _MallOrderCard extends StatelessWidget {
  final MallOrderModel order;
  const _MallOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final timeText = _formatTime(order.createdAt);

    return GestureDetector(
      onTap: () => context.push('/home/mall-order/${order.number}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('🛍️', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.number,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.firstItemSummary.isNotEmpty
                        ? order.firstItemSummary
                        : '商品 x${order.itemCount}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: CupertinoColors.tertiaryLabel,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(order.payAmountYuan),
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(status: order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int unixSeconds) => formatMallOrderTime(unixSeconds);
}

class _StatusBadge extends StatelessWidget {
  final MallOrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = mallOrderStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
