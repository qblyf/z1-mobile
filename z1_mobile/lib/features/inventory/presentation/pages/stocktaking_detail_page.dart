import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/models/stocktaking_model.dart';
import '../bloc/stocktaking_detail_bloc.dart';

class StocktakingDetailPage extends StatefulWidget {
  final int id;

  const StocktakingDetailPage({super.key, required this.id});

  @override
  State<StocktakingDetailPage> createState() => _StocktakingDetailPageState();
}

class _StocktakingDetailPageState extends State<StocktakingDetailPage> {
  late final StocktakingDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<StocktakingDetailBloc>();
    _bloc.add(StocktakingDetailLoadRequested(widget.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<StocktakingDetailBloc, StocktakingDetailState>(
        listener: (context, state) {
          if (state is StocktakingDetailOperationSuccess) {
            showCupertinoDialog(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: const Text('操作成功'),
                content: Text(state.message),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('确定'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('盘库详情'),
            ),
            child: SafeArea(
              child: _buildContent(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(StocktakingDetailState state) {
    if (state is StocktakingDetailLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state is StocktakingDetailError) {
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
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('重试'),
              onPressed: () =>
                  _bloc.add(StocktakingDetailLoadRequested(widget.id)),
            ),
          ],
        ),
      );
    }

    if (state is StocktakingDetailLoaded ||
        state is StocktakingDetailOperating ||
        state is StocktakingDetailOperationSuccess) {
      final stocktaking = state is StocktakingDetailLoaded
          ? state.stocktaking
          : state is StocktakingDetailOperating
              ? state.stocktaking
              : null;
      final products = state is StocktakingDetailLoaded
          ? state.products
          : state is StocktakingDetailOperating
              ? state.products
              : <StocktakingProductModel>[];

      if (stocktaking == null) {
        return const Center(child: Text('数据异常'));
      }

      final isOperating = state is StocktakingDetailOperating;
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

      return Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                stocktaking.code ?? '盘库单#${stocktaking.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              _StateBadge(state: stocktaking.state),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: CupertinoIcons.building_2_fill,
                            label: '仓库',
                            value: stocktaking.warehouseName ??
                                '仓库${stocktaking.warehouseID}',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: CupertinoIcons.clock,
                            label: '创建时间',
                            value: dateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  stocktaking.createdAt * 1000),
                            ),
                          ),
                          if (stocktaking.remarks != null &&
                              stocktaking.remarks!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: CupertinoIcons.doc_text,
                              label: '备注',
                              value: stocktaking.remarks!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '商品列表',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${products.length} 项',
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                if (products.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          '暂无商品',
                          style:
                              TextStyle(color: CupertinoColors.secondaryLabel),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return _ProductCard(product: product);
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              border: Border(
                top: BorderSide(color: CupertinoColors.separator),
              ),
            ),
            child: Row(
              children: [
                if (stocktaking.state == StocktakingState.inProgress) ...[
                  Expanded(
                    child: CupertinoButton(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: isOperating
                          ? null
                          : () => _showConfirmDialog('完成盘库', '确认完成此盘库？', () {
                                _bloc.add(
                                    StocktakingDetailEndRequested(widget.id));
                              }),
                      child: isOperating
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white)
                          : const Text(
                              '完成盘库',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                    ),
                  ),
                ] else if (stocktaking.state == StocktakingState.completed ||
                    stocktaking.state == StocktakingState.approved) ...[
                  Expanded(
                    child: CupertinoButton(
                      color: CupertinoColors.activeOrange,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: isOperating
                          ? null
                          : () => _showConfirmDialog('重新盘库', '确认重新开始盘库？', () {
                                _bloc.add(StocktakingDetailRestartRequested(
                                    widget.id));
                              }),
                      child: isOperating
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white)
                          : const Text(
                              '重新盘库',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: null,
                      child: const Text(
                        '编辑',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showConfirmDialog(
      String title, String content, VoidCallback onConfirm) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: const Text('确认'),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: CupertinoColors.secondaryLabel),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _StateBadge extends StatelessWidget {
  final StocktakingState state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (state) {
      case StocktakingState.draft:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        break;
      case StocktakingState.inProgress:
        bgColor = const Color(0xFFE0EDFF);
        textColor = CupertinoColors.activeBlue;
        break;
      case StocktakingState.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      case StocktakingState.approved:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        state.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final StocktakingProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final diff = product.diff;
    final isProfit = diff > 0;
    final isLoss = diff < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.productName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (product.spec != null) ...[
            const SizedBox(height: 2),
            Text(
              product.spec!,
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QuantityItem(label: '系统数量', value: product.systemQty),
              ),
              Expanded(
                child: _QuantityItem(label: '实盘数量', value: product.actualQty),
              ),
              Expanded(
                child: _QuantityItem(
                  label: '差异',
                  value: diff.abs(),
                  color: isProfit
                      ? const Color(0xFF16A34A)
                      : isLoss
                          ? const Color(0xFFDC2626)
                          : CupertinoColors.label,
                  prefix: diff > 0
                      ? '+'
                      : diff < 0
                          ? '-'
                          : '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityItem extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;
  final String prefix;

  const _QuantityItem({
    required this.label,
    required this.value,
    this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$prefix$value',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: color ?? CupertinoColors.label,
          ),
        ),
      ],
    );
  }
}
