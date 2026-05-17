import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection.dart';
import '../../data/datasources/transfer_remote_datasource.dart';
import '../../data/models/transfer_model.dart';
import '../../data/models/stocktaking_model.dart';
import '../bloc/transfer_add_bloc.dart';

class TransferAddPage extends StatefulWidget {
  const TransferAddPage({super.key});

  @override
  State<TransferAddPage> createState() => _TransferAddPageState();
}

class _TransferAddPageState extends State<TransferAddPage> {
  late final TransferAddBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = TransferAddBloc(
      dataSource: TransferRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(const TransferAddLoadWarehousesRequested());
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
      child: BlocConsumer<TransferAddBloc, TransferAddState>(
        listener: (context, state) {
          if (state is TransferAddSuccess) {
            context.pushReplacement('/inventory/transfer/${state.transferId}');
          } else if (state is TransferAddError) {
            showCupertinoDialog(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: const Text('创建失败'),
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
              middle: const Text('新建调拨'),
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

  Widget _buildContent(TransferAddState state) {
    if (state is TransferAddLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state is TransferAddError && state.warehouses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, style: const TextStyle(color: CupertinoColors.destructiveRed)),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('重试'),
              onPressed: () => _bloc.add(const TransferAddLoadWarehousesRequested()),
            ),
          ],
        ),
      );
    }

    List<WarehouseModel> warehouses = [];
    WarehouseModel? outWarehouse;
    WarehouseModel? inWarehouse;
    List<TransferGoodsItem> products = [];
    bool isSubmitting = false;

    if (state is TransferAddLoaded) {
      warehouses = state.warehouses;
      outWarehouse = state.outWarehouse;
      inWarehouse = state.inWarehouse;
      products = state.products;
    } else if (state is TransferAddSubmitting) {
      warehouses = state.warehouses;
      outWarehouse = state.outWarehouse;
      inWarehouse = state.inWarehouse;
      products = state.products;
      isSubmitting = true;
    } else if (state is TransferAddError) {
      warehouses = state.warehouses;
      outWarehouse = state.outWarehouse;
      inWarehouse = state.inWarehouse;
      products = state.products;
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(title: '调出仓库'),
                const SizedBox(height: 8),
                _WarehouseSelector(
                  warehouses: warehouses,
                  selectedWarehouse: outWarehouse,
                  placeholder: '请选择调出仓库',
                  onSelected: (w) => _bloc.add(TransferAddOutWarehouseSelected(w)),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: '调入仓库'),
                const SizedBox(height: 8),
                _WarehouseSelector(
                  warehouses: warehouses,
                  selectedWarehouse: inWarehouse,
                  placeholder: '请选择调入仓库',
                  onSelected: (w) => _bloc.add(TransferAddInWarehouseSelected(w)),
                  excludedWarehouseId: outWarehouse?.id,
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: '调拨商品'),
                const SizedBox(height: 8),
                _ProductSelector(
                  products: products,
                  onAdd: _showAddProductDialog,
                  onRemove: (productID) => _bloc.add(TransferAddProductRemoved(productID)),
                  onCountChanged: (productID, count) =>
                      _bloc.add(TransferAddProductCountChanged(productID: productID, count: count)),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            border: Border(top: BorderSide(color: CupertinoColors.separator)),
          ),
          child: SafeArea(
            top: false,
            child: CupertinoButton(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(12),
              onPressed: _canSubmit(outWarehouse, inWarehouse, products) && !isSubmitting
                  ? () => _bloc.add(const TransferAddSubmitted())
                  : null,
              child: isSubmitting
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Text(
                      '创建调拨单',
                      style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canSubmit(WarehouseModel? out, WarehouseModel? inWarehouse, List<TransferGoodsItem> products) {
    return out != null && inWarehouse != null && products.isNotEmpty && out.id != inWarehouse.id;
  }

  void _showAddProductDialog() {
    final productIdController = TextEditingController();
    final countController = TextEditingController(text: '1');

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('添加商品'),
        content: Column(
          children: [
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: productIdController,
              placeholder: '商品ID',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: countController,
              placeholder: '数量',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: const Text('添加'),
            onPressed: () {
              final productId = int.tryParse(productIdController.text);
              final count = int.tryParse(countController.text);
              if (productId != null && productId > 0 && count != null && count > 0) {
                Navigator.pop(ctx);
                _bloc.add(TransferAddProductSelected(
                  TransferGoodsItem(productID: productId, count: count),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
    );
  }
}

class _WarehouseSelector extends StatelessWidget {
  final List<WarehouseModel> warehouses;
  final WarehouseModel? selectedWarehouse;
  final String placeholder;
  final ValueChanged<WarehouseModel> onSelected;
  final int? excludedWarehouseId;

  const _WarehouseSelector({
    required this.warehouses,
    required this.selectedWarehouse,
    required this.placeholder,
    required this.onSelected,
    this.excludedWarehouseId,
  });

  @override
  Widget build(BuildContext context) {
    final availableWarehouses = excludedWarehouseId != null
        ? warehouses.where((w) => w.id != excludedWarehouseId).toList()
        : warehouses;

    return GestureDetector(
      onTap: () => _showPicker(context, availableWarehouses),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.separator),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedWarehouse?.name ?? placeholder,
              style: TextStyle(
                color: selectedWarehouse != null ? CupertinoColors.label : CupertinoColors.tertiaryLabel,
              ),
            ),
            const Icon(CupertinoIcons.chevron_down, color: CupertinoColors.secondaryLabel, size: 18),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, List<WarehouseModel> warehouses) {
    if (warehouses.isEmpty) return;

    int selectedIndex = 0;
    if (selectedWarehouse != null) {
      selectedIndex = warehouses.indexWhere((w) => w.id == selectedWarehouse!.id);
      if (selectedIndex < 0) selectedIndex = 0;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onSelected(warehouses[selectedIndex]);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                onSelectedItemChanged: (index) => selectedIndex = index,
                children: warehouses.map((w) => Center(child: Text(w.name))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSelector extends StatelessWidget {
  final List<TransferGoodsItem> products;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int productID, int count) onCountChanged;

  const _ProductSelector({
    required this.products,
    required this.onAdd,
    required this.onRemove,
    required this.onCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (products.isNotEmpty) ...[
          ...products.map((product) => _ProductItemCard(
                product: product,
                onRemove: () => onRemove(product.productID),
                onCountChanged: (count) => onCountChanged(product.productID, count),
              )),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CupertinoColors.separator, style: BorderStyle.solid),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.plus_circle, color: CupertinoColors.activeBlue, size: 18),
                SizedBox(width: 8),
                Text(
                  '添加商品',
                  style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductItemCard extends StatelessWidget {
  final TransferGoodsItem product;
  final VoidCallback onRemove;
  final ValueChanged<int> onCountChanged;

  const _ProductItemCard({
    required this.product,
    required this.onRemove,
    required this.onCountChanged,
  });

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
                  '商品ID: ${product.productID}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (product.productName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    product.productName!,
                    style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 28,
                child: const Icon(CupertinoIcons.minus_circle, size: 22),
                onPressed: () {
                  if (product.count > 1) {
                    onCountChanged(product.count - 1);
                  }
                },
              ),
              Text(
                '${product.count}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 28,
                child: const Icon(CupertinoIcons.plus_circle, size: 22),
                onPressed: () => onCountChanged(product.count + 1),
              ),
            ],
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 28,
            child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}