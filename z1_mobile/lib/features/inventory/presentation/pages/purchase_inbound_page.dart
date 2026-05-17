import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/models/purchase_model.dart';
import '../bloc/purchase_inbound_bloc.dart';

class PurchaseInboundPage extends StatefulWidget {
  final int id;

  const PurchaseInboundPage({super.key, required this.id});

  @override
  State<PurchaseInboundPage> createState() => _PurchaseInboundPageState();
}

class _PurchaseInboundPageState extends State<PurchaseInboundPage> {
  late final PurchaseInboundBloc _bloc;
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = PurchaseInboundBloc(
      dataSource: PurchaseRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(PurchaseInboundLoadRequested(widget.id));
  }

  @override
  void dispose() {
    _bloc.close();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PurchaseInboundBloc, PurchaseInboundState>(
        listener: (context, state) {
          if (state is PurchaseInboundSuccess) {
            showCupertinoDialog(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: const Text('入库成功'),
                content: Text(state.message),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop();
                      context.pop();
                    },
                  ),
                ],
              ),
            );
          } else if (state is PurchaseInboundError) {
            showCupertinoDialog(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: const Text('操作失败'),
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
            navigationBar: CupertinoNavigationBar(
              middle: Text('采购入库 #${widget.id}'),
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

  Widget _buildContent(PurchaseInboundState state) {
    if (state is PurchaseInboundLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state is PurchaseInboundError) {
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
              onPressed: () => _bloc.add(PurchaseInboundLoadRequested(widget.id)),
            ),
          ],
        ),
      );
    }

    if (state is PurchaseInboundReady) {
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
                                  state.purchase.code ?? '采购单#${state.purchase.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              _StateBadge(state: state.purchase.state),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '供应商: ${state.purchase.supplierName ?? "-"}',
                            style: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 13,
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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '选择仓库',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showWarehousePicker(context, state.warehouses),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      state.selectedWarehouse?.name ?? '请选择仓库',
                                      style: TextStyle(
                                        color: state.selectedWarehouse != null
                                            ? CupertinoColors.label
                                            : CupertinoColors.placeholderText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 16,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '入库商品',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${state.purchase.products.length} 项',
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
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.purchase.products[index];
                        return _InboundProductCard(
                          product: product,
                          count: state.productCounts[product.productId] ?? product.remainCount,
                          onCountChanged: (count) {
                            _bloc.add(PurchaseInboundProductCountUpdated(
                              productId: product.productId,
                              count: count,
                            ));
                          },
                        );
                      },
                      childCount: state.purchase.products.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '备注',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                            controller: _remarksController,
                            placeholder: '选填，可输入入库备注',
                            maxLines: 2,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onChanged: (value) {
                              _bloc.add(PurchaseInboundRemarksChanged(value));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: state.isSubmitting ||
                          state.selectedWarehouse == null
                      ? null
                      : () => _bloc.add(const PurchaseInboundSubmitRequested()),
                  child: state.isSubmitting
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : const Text(
                          '确认入库',
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

  void _showWarehousePicker(BuildContext context, List<WarehouseModel> warehouses) {
    if (warehouses.isEmpty) return;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('选择仓库'),
        actions: warehouses.map((w) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _bloc.add(PurchaseInboundWarehouseSelected(w));
            },
            child: Text(w.name),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDestructiveAction: true,
          child: const Text('取消'),
        ),
      ),
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

class _InboundProductCard extends StatefulWidget {
  final PurchaseProductModel product;
  final int count;
  final ValueChanged<int> onCountChanged;

  const _InboundProductCard({
    required this.product,
    required this.count,
    required this.onCountChanged,
  });

  @override
  State<_InboundProductCard> createState() => _InboundProductCardState();
}

class _InboundProductCardState extends State<_InboundProductCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.count.toString());
  }

  @override
  void didUpdateWidget(_InboundProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count && _controller.text != widget.count.toString()) {
      _controller.text = widget.count.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            widget.product.productName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (widget.product.spec != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.product.spec!,
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '可入库: ',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 12,
                ),
              ),
              Text(
                '${widget.product.remainCount}',
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                '单价: ',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 12,
                ),
              ),
              Text(
                widget.product.formattedPrice,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '入库数量',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (widget.count > 0) {
                    widget.onCountChanged(widget.count - 1);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.minus,
                      size: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: CupertinoTextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 0;
                    widget.onCountChanged(count);
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onCountChanged(widget.count + 1);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.plus,
                      size: 14,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}