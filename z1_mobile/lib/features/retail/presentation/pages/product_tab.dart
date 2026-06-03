import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../bloc/product_select_bloc.dart';
import 'sku_select_modal.dart';

class ProductTab extends StatefulWidget {
  final void Function(List<CartSkuItem> cartItems) onCartChanged;

  const ProductTab({super.key, required this.onCartChanged});

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  final TextEditingController _searchController = TextEditingController();

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
              // Header with back button and breadcrumb
              _buildHeader(context, state),
              // Search Bar
              _buildSearchBar(context),
              // Main Content: Sidebar + Grid
              Expanded(
                child: _buildMainContent(context, state),
              ),
              // Cart Bar
              if (state.cartTotalQuantity > 0)
                _buildCartBar(context, state),
            ],
          );
        }
        return const Center(child: Text('请搜索商品'));
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProductSelectLoaded state) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (state.canGoBack)
            GestureDetector(
              onTap: () => context.read<ProductSelectBloc>().add(const ProductSelectBackPressed()),
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(CupertinoIcons.chevron_left, color: CupertinoColors.activeBlue, size: 20),
              ),
            ),
          Expanded(
            child: Text(
              state.breadcrumbTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.label,
              ),
              textAlign: state.canGoBack ? TextAlign.left : TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: CupertinoColors.systemGroupedBackground,
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _searchController,
              placeholder: '搜索商品名称',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(CupertinoIcons.search, color: CupertinoColors.secondaryLabel, size: 18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              onChanged: (value) {
                context.read<ProductSelectBloc>().add(ProductSelectSearchChanged(value));
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // TODO(扫码): 接入 mobile_scanner 包，扫到的条码写入搜索框并触发 ProductSelectSearchChanged
              // 同步实现：service_tab.dart 的同名按钮
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(CupertinoIcons.camera, color: CupertinoColors.secondaryLabel, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ProductSelectLoaded state) {
    return Row(
      children: [
        // Left Sidebar (30%)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.30,
          child: Container(
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              border: Border(
                right: BorderSide(color: CupertinoColors.separator, width: 0.5),
              ),
            ),
            child: _buildCategorySidebar(context, state),
          ),
        ),
        // Right Content (70%)
        Expanded(
          child: _buildSpuGrid(context, state),
        ),
      ],
    );
  }

  Widget _buildCategorySidebar(BuildContext context, ProductSelectLoaded state) {
    final categories = state.currentSidebarCategories;

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = state.currentCategoryId == category.id;

        return GestureDetector(
          onTap: () {
            context.read<ProductSelectBloc>().add(ProductSelectCategoryTapped(category.id));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8F4FF) : null,
              border: Border(
                left: BorderSide(
                  color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.white,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              category.title,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.label,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpuGrid(BuildContext context, ProductSelectLoaded state) {
    final displaySpus = state.displaySpus;

    if (state.isLoadingSpus) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (displaySpus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.cube_box, size: 48, color: CupertinoColors.systemGrey),
            const SizedBox(height: 12),
            Text(
              state.navigationStack.isEmpty ? '请选择分类' : '暂无商品',
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          ],
        ),
      );
    }

    // Grid title - show count only, breadcrumb is in header
    final spuCount = displaySpus.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Text(
            '共 $spuCount 件商品',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: displaySpus.length,
            itemBuilder: (context, index) {
              final spu = displaySpus[index];
              return _SpuCard(
                spu: spu,
                onTap: () => _showSkuModal(context, spu),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSkuModal(BuildContext context, SpuModel spu) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: SkuSelectModal(
          spu: spu,
          onAddToCart: (sku) {
            context.read<ProductSelectBloc>().add(ProductSelectSkuAdded(sku: sku));
          },
          onSelectGoods: (spuId) {
            // TODO(序列号商品选择页): hasSerial=2 时跳转到独立 goods 选择页（按 SPU 列出可选 serial 编号 → 加入购物车）
            // 依赖：1) 新路由 /home/retail/goods-select?spuId=xxx  2) GoodsSelectPage  3) /serial/list-by-spu API
            debugPrint('SPU $spuId 需要选择具体商品（hasSerial=2）');
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
              widget.onCartChanged(state.cartItems);
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
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
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
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              alignment: Alignment.center,
              child: spu.image != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
                Text(
                  spu.spuName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spu.priceDisplay,
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (spu.saleStock != null)
                            Text(
                              '库存: ${spu.saleStock}',
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
              CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.minus_circle, size: 22), onPressed: () => onQuantityChanged(-1)),
              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.plus_circle, size: 22), onPressed: () => onQuantityChanged(1)),
            ],
          ),
          const SizedBox(width: 8),
          Text(formatter.format(item.subtotal / 100), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
