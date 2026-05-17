import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/models/purchase_model.dart';
import '../bloc/purchase_detail_bloc.dart';

class PurchaseDetailPage extends StatefulWidget {
  final int id;

  const PurchaseDetailPage({super.key, required this.id});

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  late final PurchaseDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PurchaseDetailBloc(
      dataSource: PurchaseRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(PurchaseDetailLoadRequested(widget.id));
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
      child: BlocBuilder<PurchaseDetailBloc, PurchaseDetailState>(
        builder: (context, state) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text('采购详情 #${widget.id}'),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back),
                onPressed: () => context.pop(),
              ),
            ),
            child: SafeArea(
              child: _buildContent(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(PurchaseDetailState state) {
    if (state is PurchaseDetailLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state is PurchaseDetailError) {
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
              onPressed: () => _bloc.add(PurchaseDetailLoadRequested(widget.id)),
            ),
          ],
        ),
      );
    }

    if (state is PurchaseDetailLoaded) {
      final purchase = state.purchase;
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
                              Expanded(
                                child: Text(
                                  purchase.code ?? '采购单#${purchase.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              _StateBadge(state: purchase.state),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: CupertinoIcons.building_2_fill,
                            label: '供应商',
                            value: purchase.supplierName ?? '-',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: CupertinoIcons.clock,
                            label: '创建时间',
                            value: dateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(purchase.createdAt * 1000),
                            ),
                          ),
                          if (purchase.remarks != null && purchase.remarks!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: CupertinoIcons.doc_text,
                              label: '备注',
                              value: purchase.remarks!,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '共 ${purchase.products.length} 项',
                                  style: const TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  purchase.formattedAmount,
                                  style: const TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                          '${purchase.products.length} 项',
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
                if (purchase.products.isEmpty)
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
                          final product = purchase.products[index];
                          return _ProductCard(product: product);
                        },
                        childCount: purchase.products.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          if (purchase.state != PurchaseState.completed)
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
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () => context.push('/inventory/purchase-inbound/${widget.id}'),
                    child: const Text(
                      '采购入库',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
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
  final PurchaseState state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (state) {
      case PurchaseState.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case PurchaseState.partial:
        bgColor = const Color(0xFFE0EDFF);
        textColor = CupertinoColors.activeBlue;
        break;
      case PurchaseState.completed:
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
  final PurchaseProductModel product;

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
          if (product.barcode != null) ...[
            const SizedBox(height: 2),
            Text(
              product.barcode!,
              style: const TextStyle(
                color: CupertinoColors.tertiaryLabel,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '单价',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '采购数量',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.count}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '已入库',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.inboundCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: product.inboundCount > 0
                            ? const Color(0xFF16A34A)
                            : CupertinoColors.label,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}