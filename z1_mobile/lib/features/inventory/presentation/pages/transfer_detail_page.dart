import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/datasources/transfer_remote_datasource.dart';
import '../../data/models/transfer_model.dart';
import '../bloc/transfer_detail_bloc.dart';

class TransferDetailPage extends StatefulWidget {
  final int id;

  const TransferDetailPage({super.key, required this.id});

  @override
  State<TransferDetailPage> createState() => _TransferDetailPageState();
}

class _TransferDetailPageState extends State<TransferDetailPage> {
  late final TransferDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = TransferDetailBloc(
      dataSource: TransferRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(TransferDetailLoadRequested(widget.id));
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
      child: BlocConsumer<TransferDetailBloc, TransferDetailState>(
        listener: (context, state) {
          if (state is TransferDetailOperationSuccess) {
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
              middle: Text('调拨详情'),
            ),
            child: SafeArea(
              child: _buildContent(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(TransferDetailState state) {
    if (state is TransferDetailLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state is TransferDetailError) {
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
              onPressed: () => _bloc.add(TransferDetailLoadRequested(widget.id)),
            ),
          ],
        ),
      );
    }

    if (state is TransferDetailLoaded ||
        state is TransferDetailOperating ||
        state is TransferDetailOperationSuccess) {
      final transfer = state is TransferDetailLoaded
          ? state.transfer
          : state is TransferDetailOperating
              ? state.transfer
              : null;

      if (transfer == null) {
        return const Center(child: Text('数据异常'));
      }

      final isOperating = state is TransferDetailOperating;
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
                                transfer.code ?? '调拨单#${transfer.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              _StateBadge(state: transfer.state),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: CupertinoIcons.arrow_right,
                            label: '调出仓库',
                            value: transfer.fromWarehouseName ?? '仓库${transfer.fromWarehouseID}',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: CupertinoIcons.arrow_left,
                            label: '调入仓库',
                            value: transfer.toWarehouseName ?? '仓库${transfer.toWarehouseID}',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: CupertinoIcons.clock,
                            label: '创建时间',
                            value: dateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(transfer.createdAt * 1000),
                            ),
                          ),
                          if (transfer.shippedAt != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: CupertinoIcons.cube_box,
                              label: '发货时间',
                              value: dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(transfer.shippedAt! * 1000),
                              ),
                            ),
                          ],
                          if (transfer.receivedAt != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: CupertinoIcons.checkmark_circle,
                              label: '入库时间',
                              value: dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(transfer.receivedAt! * 1000),
                              ),
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
                          '${transfer.goodsInfo.length} 项',
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
                if (transfer.goodsInfo.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          '暂无商品',
                          style: TextStyle(color: CupertinoColors.secondaryLabel),
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
                          final product = transfer.goodsInfo[index];
                          return _ProductCard(product: product);
                        },
                        childCount: transfer.goodsInfo.length,
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
            child: SafeArea(
              top: false,
              child: _buildActionButtons(transfer, isOperating),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(TransferDetailModel transfer, bool isOperating) {
    if (transfer.state == TransferState.pending) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          borderRadius: BorderRadius.circular(12),
          onPressed: isOperating
              ? null
              : () => _showConfirmDialog('确认发货', '确认此调拨单已发货？', () {
                    _bloc.add(TransferDetailShippingRequested(widget.id));
                  }),
          child: isOperating
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : const Text(
                  '确认发货',
                  style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.white),
                ),
        ),
      );
    } else if (transfer.state == TransferState.shipping) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: const Color(0xFF16A34A),
          borderRadius: BorderRadius.circular(12),
          onPressed: isOperating
              ? null
              : () => _showConfirmDialog('确认入库', '确认此调拨单已入库？', () {
                    _bloc.add(TransferDetailReceivedRequested(widget.id));
                  }),
          child: isOperating
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : const Text(
                  '确认入库',
                  style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.white),
                ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
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
  final TransferState state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (state) {
      case TransferState.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        break;
      case TransferState.shipping:
        bgColor = const Color(0xFFE0EDFF);
        textColor = CupertinoColors.activeBlue;
        break;
      case TransferState.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
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
  final TransferGoodsItem product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName ?? '商品ID: ${product.productID}',
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
                if (product.barcode != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '条码: ${product.barcode}',
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '×${product.count}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (product.actualCount != null) ...[
                const SizedBox(height: 2),
                Text(
                  '实收: ${product.actualCount}',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}