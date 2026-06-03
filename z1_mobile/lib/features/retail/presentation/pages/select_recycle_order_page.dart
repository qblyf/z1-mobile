import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/recycle_order_remote_datasource.dart';
import '../../data/models/recycle_order_model.dart';
import '../bloc/recycle_order_bloc.dart';

/// 回收单选择页面
/// 用于零售开单中选择可绑定的回收单（以旧换新场景）
class SelectRecycleOrderPage extends StatelessWidget {
  const SelectRecycleOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RecycleOrderBloc(
        dataSource: RecycleOrderRemoteDataSourceImpl(
          apiClient: ctx.read<dynamic>(),
        ),
      )..add(const RecycleOrderLoadRequested()),
      child: const _SelectRecycleOrderView(),
    );
  }
}

class _SelectRecycleOrderView extends StatefulWidget {
  const _SelectRecycleOrderView();

  @override
  State<_SelectRecycleOrderView> createState() => _SelectRecycleOrderViewState();
}

class _SelectRecycleOrderViewState extends State<_SelectRecycleOrderView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('选择回收单'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('取消'),
          onPressed: () => context.pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('确定'),
          onPressed: () => _onConfirm(context),
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<RecycleOrderBloc, RecycleOrderState>(
          builder: (context, state) {
            if (state is RecycleOrderLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (state is RecycleOrderError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_circle,
                        size: 48, color: CupertinoColors.destructiveRed),
                    const SizedBox(height: 16),
                    Text(state.message,
                        style: const TextStyle(color: CupertinoColors.secondaryLabel)),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      child: const Text('重试'),
                      onPressed: () =>
                          context.read<RecycleOrderBloc>().add(const RecycleOrderLoadRequested()),
                    ),
                  ],
                ),
              );
            }
            if (state is RecycleOrderLoaded) {
              final orders = state.bindableOrders;

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.gift,
                          size: 64, color: CupertinoColors.systemGrey),
                      const SizedBox(height: 16),
                      const Text('暂无可绑定回收单'),
                      const SizedBox(height: 8),
                      Text(
                        '请先在回收系统创建以旧换新订单',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.systemGrey.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        child: const Text('重试'),
                        onPressed: () =>
                            context.read<RecycleOrderBloc>().add(const RecycleOrderLoadRequested()),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (ctx, index) {
                        final order = orders[index];
                        final isSelected = state.selectedOrder?.id == order.id;
                        return _RecycleOrderCard(
                          order: order,
                          isSelected: isSelected,
                          onTap: () {
                            context.read<RecycleOrderBloc>().add(
                                  RecycleOrderSelectionToggled(order),
                                );
                          },
                        );
                      },
                    ),
                  ),
                  _buildBottomBar(context, state),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, RecycleOrderLoaded state) {
    final selectedOrder = state.selectedOrder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedOrder != null ? '已选 1 个' : '未选择',
                  style: const TextStyle(fontSize: 13),
                ),
                if (selectedOrder != null)
                  Text(
                    '补贴 ¥${(selectedOrder.subsidyAmount / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.activeGreen,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              borderRadius: BorderRadius.circular(20),
              onPressed: selectedOrder != null
                  ? () {
                      context.pop({
                        'order': selectedOrder,
                        'subsidyAmount': selectedOrder.subsidyAmount,
                      });
                    }
                  : null,
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirm(BuildContext context) {
    final state = context.read<RecycleOrderBloc>().state;
    if (state is RecycleOrderLoaded && state.selectedOrder != null) {
      context.pop({
        'order': state.selectedOrder,
        'subsidyAmount': state.selectedOrder!.subsidyAmount,
      });
    } else {
      context.pop();
    }
  }
}

class _RecycleOrderCard extends StatelessWidget {
  final RecycleOrderModel order;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecycleOrderCard({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B35)
                : CupertinoColors.systemGrey5,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 左侧补贴金额区域
            Container(
              width: 90,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.subsidyAmountDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const Text(
                    '回收补贴',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            // 右侧详情区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: Color(0xFFFF6B35),
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (order.productName != null)
                      Text(
                        order.productName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          size: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(order.createTime),
                          style: const TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                    if (order.customerName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '客户：${order.customerName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
