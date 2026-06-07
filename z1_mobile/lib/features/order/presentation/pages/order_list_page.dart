import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/datasources/order_list_remote_datasource.dart';
import '../../data/models/order_model.dart';
import '../bloc/order_list_bloc.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late final ScrollController _scrollController;
  late final OrderListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _bloc = getIt<OrderListBloc>();
    _bloc.add(const OrderListLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _bloc.add(const OrderListLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('订单列表'),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFilterTabs(),
              Expanded(
                child: BlocBuilder<OrderListBloc, OrderListState>(
                  builder: (context, state) {
                    if (state is OrderListLoading) {
                      return const Center(child: CupertinoActivityIndicator());
                    }

                    if (state is OrderListError) {
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
                              state.message,
                              style: const TextStyle(
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              child: const Text('重试'),
                              onPressed: () =>
                                  _bloc.add(const OrderListRefreshRequested()),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is OrderListLoaded ||
                        state is OrderListLoadingMore) {
                      final orders = state is OrderListLoaded
                          ? state.orders
                          : (state as OrderListLoadingMore).orders;
                      final isLoadingMore = state is OrderListLoadingMore;

                      if (orders.isEmpty) {
                        return const Center(
                          child: Text(
                            '暂无订单',
                            style: TextStyle(
                                color: CupertinoColors.secondaryLabel),
                          ),
                        );
                      }

                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () async {
                              _bloc.add(const OrderListRefreshRequested());
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
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
                                            child: Center(
                                              child:
                                                  CupertinoActivityIndicator(),
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _OrderCard(order: orders[index]),
                                  );
                                },
                                childCount:
                                    orders.length + (isLoadingMore ? 1 : 0),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return BlocBuilder<OrderListBloc, OrderListState>(
      builder: (context, state) {
        final selectedRange = state is OrderListLoaded
            ? state.dateRange
            : (state is OrderListLoadingMore
                ? state.dateRange
                : DateRange.today);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _FilterTab(
                label: '今日',
                isSelected: selectedRange == DateRange.today,
                onTap: () =>
                    _bloc.add(const OrderListDateRangeChanged(DateRange.today)),
              ),
              const SizedBox(width: 12),
              _FilterTab(
                label: '本周',
                isSelected: selectedRange == DateRange.week,
                onTap: () =>
                    _bloc.add(const OrderListDateRangeChanged(DateRange.week)),
              ),
              const SizedBox(width: 12),
              _FilterTab(
                label: '本月',
                isSelected: selectedRange == DateRange.month,
                onTap: () =>
                    _bloc.add(const OrderListDateRangeChanged(DateRange.month)),
              ),
              const SizedBox(width: 12),
              _FilterTab(
                label: '全部',
                isSelected: selectedRange == DateRange.all,
                onTap: () =>
                    _bloc.add(const OrderListDateRangeChanged(DateRange.all)),
              ),
            ],
          ),
        );
      },
    );
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
          color:
              isSelected ? CupertinoColors.activeBlue : CupertinoColors.white,
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
            color: isSelected ? CupertinoColors.white : CupertinoColors.label,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return GestureDetector(
      onTap: () => context.push('/order/${order.orderNumber}'),
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
              child: const Text('📦', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.timeAgo} · ${order.customerName.isEmpty ? '散客' : order.customerName}',
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
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
                  currencyFormat.format(order.finalAmountYuan),
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: order.statusEnum == OrderStatus.completed
                        ? const Color(0xFFDCFCE7)
                        : order.statusEnum == OrderStatus.refunded
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFE0EDFF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: order.statusEnum == OrderStatus.completed
                          ? const Color(0xFF16A34A)
                          : order.statusEnum == OrderStatus.refunded
                              ? const Color(0xFFDC2626)
                              : CupertinoColors.activeBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
