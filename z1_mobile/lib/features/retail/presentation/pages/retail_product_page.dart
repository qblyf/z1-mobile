import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/retail_order_model.dart';
import '../bloc/product_bloc.dart';

/// 商品选购页
class RetailProductPage extends StatefulWidget {
  final RetailOrder? initialOrder;

  const RetailProductPage({super.key, this.initialOrder});

  @override
  State<RetailProductPage> createState() => _RetailProductPageState();
}

class _RetailProductPageState extends State<RetailProductPage> {
  late RetailOrder _order;
  final TextEditingController _searchController = TextEditingController();
  final List<ProductItem> _cart = [];
  int _selectedCategoryIndex = 0;
  Timer? _debounceTimer;

  final List<String> _categories = ['全部', '黄金', '钻石', '翡翠', '银饰', '定制'];

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder ?? const RetailOrder();
    context.read<ProductBloc>().add(const ProductLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<ProductBloc>().add(ProductSearchRequested(value));
    });
  }

  void _onCategoryChanged(int index) {
    setState(() => _selectedCategoryIndex = index);
    context.read<ProductBloc>().add(ProductCategoryChanged(_categories[index]));
  }

  double get _cartTotalYuan {
    return _cart.fold<int>(0, (sum, p) => sum + p.totalDiscountPrice) / 100;
  }

  void _addToCart(ProductItem product) {
    setState(() {
      final existing = _cart.indexWhere((p) => p.productID == product.productID);
      if (existing >= 0) {
        final p = _cart[existing];
        _cart[existing] = p.copyWith(
          quantity: p.quantity + 1,
          totalDiscountPrice: p.discountPrice * (p.quantity + 1),
        );
      } else {
        _cart.add(product.copyWith(
          quantity: 1,
          discountPrice: product.price,
          totalDiscountPrice: product.price,
        ));
      }
    });
  }

  void _updateQuantity(ProductItem product, int delta) {
    setState(() {
      final index = _cart.indexWhere((p) => p.productID == product.productID);
      if (index >= 0) {
        final p = _cart[index];
        final newQty = p.quantity + delta;
        if (newQty <= 0) {
          _cart.removeAt(index);
        } else {
          _cart[index] = p.copyWith(
            quantity: newQty,
            totalDiscountPrice: p.discountPrice * newQty,
          );
        }
      }
    });
  }

  void _goToConfirm() {
    if (_cart.isEmpty) {
      _showError('请先添加商品');
      return;
    }

    final order = _order.copyWith(products: List.from(_cart));
    context.push('/order/retail/confirm', extra: order);
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('商品选购'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.cart),
          onPressed: () => _showCartSheet(context, currencyFormat),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: CupertinoColors.systemGroupedBackground,
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: '搜索商品名称/编码',
                onChanged: _onSearchChanged,
              ),
            ),

            Container(
              height: 44,
              color: CupertinoColors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () => _onCategoryChanged(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? CupertinoColors.activeBlue : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _categories[index],
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
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message, style: const TextStyle(color: CupertinoColors.destructiveRed)),
                          const SizedBox(height: 12),
                          CupertinoButton(
                            child: const Text('重试'),
                            onPressed: () => context.read<ProductBloc>().add(const ProductLoadRequested()),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is ProductLoaded || state is ProductSearching) {
                    final products = state is ProductLoaded
                        ? state.filteredProducts
                        : (state as ProductSearching).allProducts;
                    if (products.isEmpty) {
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
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductCard(
                          name: product.productName,
                          price: product.price,
                          onAdd: () {
                            final item = ProductItem(
                              productID: product.productID,
                              productName: product.productName,
                              price: product.price,
                              quantity: 1,
                              discountPrice: product.price,
                              totalDiscountPrice: product.price,
                            );
                            _addToCart(item);
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: Text('请搜索商品'));
                },
              ),
            ),

            if (_cart.isNotEmpty)
              Container(
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
                      onTap: () => _showCartSheet(context, currencyFormat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.cart_fill,
                              color: CupertinoColors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_cart.fold<int>(0, (sum, p) => sum + p.quantity)}',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                          const Text(
                            '合计',
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            currencyFormat.format(_cartTotalYuan),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      borderRadius: BorderRadius.circular(20),
                      onPressed: _goToConfirm,
                      child: const Text('去结算'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context, NumberFormat formatter) {
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
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '购物车',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('清空'),
                    onPressed: () => setState(() => _cart.clear()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('购物车为空'))
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatter.format(item.priceYuan),
                                      style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 28,
                                    child: const Icon(CupertinoIcons.minus_circle, size: 22),
                                    onPressed: () => _updateQuantity(item, -1),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 28,
                                    child: const Icon(CupertinoIcons.plus_circle, size: 22),
                                    onPressed: () => _updateQuantity(item, 1),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(item.totalPriceYuan),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_cart.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '合计: ${formatter.format(_cartTotalYuan)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(20),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _goToConfirm();
                      },
                      child: const Text('去结算'),
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

class _ProductCard extends StatelessWidget {
  final String name;
  final int price;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              alignment: Alignment.center,
              child: const Icon(CupertinoIcons.cube_box, size: 48, color: CupertinoColors.systemGrey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(price / 100),
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.plus,
                          color: CupertinoColors.white,
                          size: 14,
                        ),
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