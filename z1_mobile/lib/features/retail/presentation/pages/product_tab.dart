import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../bloc/product_select_bloc.dart';
import 'sku_select_modal.dart';

class ProductTab extends StatefulWidget {
  final void Function(CartSkuItem item) onCartChanged;

  const ProductTab({super.key, required this.onCartChanged});

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductSelectBloc>().add(const ProductSelectLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductSelectBloc, ProductSelectState>(
      builder: (context, state) {
        if (state is ProductSelectLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is ProductSelectError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: CupertinoColors.destructiveRed)),
                const SizedBox(height: 12),
                CupertinoButton(
                  child: const Text('重试'),
                  onPressed: () => context.read<ProductSelectBloc>().add(const ProductSelectLoadRequested()),
                ),
              ],
            ),
          );
        }
        if (state is ProductSelectLoaded) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: CupertinoColors.systemGroupedBackground,
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: '搜索商品名称/条码',
                  onChanged: (value) {
                    context.read<ProductSelectBloc>().add(ProductSelectSearchChanged(value));
                  },
                ),
              ),
              Container(
                height: 44,
                color: CupertinoColors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.categories.length + 1,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    final label = index == 0 ? '全部' : state.categories[index - 1].name;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryIndex = index);
                        context.read<ProductSelectBloc>().add(ProductSelectCategoryChanged(index));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? CupertinoColors.activeBlue : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? CupertinoColors.white : CupertinoColors.label,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildSpuGrid(state),
              ),
              if (state.cartTotalQuantity > 0)
                _buildCartBar(context, state),
            ],
          );
        }
        return const Center(child: Text('请搜索商品'));
      },
    );
  }

  Widget _buildSpuGrid(ProductSelectLoaded state) {
    final categories = state.searchKeyword.isEmpty && _selectedCategoryIndex == 0
        ? state.categories
        : state.filteredCategories;

    final displayCategories = _selectedCategoryIndex == 0
        ? categories
        : (_selectedCategoryIndex <= state.categories.length
            ? [state.categories[_selectedCategoryIndex - 1]]
            : categories);

    if (displayCategories.isEmpty || displayCategories.every((c) => c.spus.isEmpty)) {
      return const Center(child: Text('暂无商品'));
    }

    final allSpus = <SpuModel>[];
    for (final cat in displayCategories) {
      allSpus.addAll(cat.spus);
    }

    if (allSpus.isEmpty) {
      return const Center(child: Text('暂无商品'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: allSpus.length,
      itemBuilder: (context, index) {
        final spu = allSpus[index];
        return _SpuCard(
          spu: spu,
          onTap: () => _showSkuModal(context, spu),
        );
      },
    );
  }

  void _showSkuModal(BuildContext context, SpuModel spu) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SkuSelectModal(
          spu: spu,
          onAddToCart: (sku) {
            context.read<ProductSelectBloc>().add(ProductSelectSkuAdded(sku: sku));
          },
        ),
      ),
    );
  }

  Widget _buildCartBar(BuildContext context, ProductSelectLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showCartSheet(context, state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.cart_fill, color: CupertinoColors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${state.cartTotalQuantity}',
                    style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('合计', style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11)),
                Text(currencyFormat.format(state.cartTotalPrice / 100), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            borderRadius: BorderRadius.circular(20),
            onPressed: () {
              for (final item in state.cartItems) {
                widget.onCartChanged(item);
              }
            },
            child: const Text('去结算'),
          ),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context, ProductSelectLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.separator))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('购物车 (${state.cartTotalQuantity}件)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('清空'),
                    onPressed: () {
                      for (final item in state.cartItems) {
                        context.read<ProductSelectBloc>().add(ProductSelectSkuAdded(sku: item.sku, quantity: -item.quantity));
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.cartItems.isEmpty
                  ? const Center(child: Text('购物车为空'))
                  : ListView.builder(
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return _CartSkuItem(
                          item: item,
                          formatter: currencyFormat,
                          onQuantityChanged: (delta) {
                            if (item.quantity + delta <= 0) {
                              context.read<ProductSelectBloc>().add(ProductSelectSkuAdded(sku: item.sku, quantity: -item.quantity));
                            } else {
                              context.read<ProductSelectBloc>().add(ProductSelectSkuAdded(sku: item.sku, quantity: delta));
                            }
                          },
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合计: ${currencyFormat.format(state.cartTotalPrice / 100)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('继续添加'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpuCard extends StatelessWidget {
  final SpuModel spu;
  final VoidCallback onTap;

  const _SpuCard({required this.spu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: CupertinoColors.systemGrey.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              alignment: Alignment.center,
              child: spu.image != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(spu.image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    )
                  : const Icon(CupertinoIcons.cube_box, size: 48, color: CupertinoColors.systemGrey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spu.spuName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currencyFormat.format((spu.retailPrice ?? 0) / 100), style: const TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold, fontSize: 13)),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: CupertinoColors.activeBlue, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(CupertinoIcons.plus, color: CupertinoColors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSkuItem extends StatelessWidget {
  final CartSkuItem item;
  final NumberFormat formatter;
  final Function(int) onQuantityChanged;

  const _CartSkuItem({required this.item, required this.formatter, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.separator))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.sku.skuName, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(formatter.format(item.sku.price / 100), style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(padding: EdgeInsets.zero, minSize: 28, child: const Icon(CupertinoIcons.minus_circle, size: 22), onPressed: () => onQuantityChanged(-1)),
              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              CupertinoButton(padding: EdgeInsets.zero, minSize: 28, child: const Icon(CupertinoIcons.plus_circle, size: 22), onPressed: () => onQuantityChanged(1)),
            ],
          ),
          const SizedBox(width: 8),
          Text(formatter.format(item.subtotal / 100), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}