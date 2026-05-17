import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/retail_order_model.dart';

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

  final List<String> _categories = ['全部', '黄金', '钻石', '翡翠', '银饰', '定制'];
  final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': '黄金手镯 999', 'price': 59800, 'category': '黄金'},
    {'id': 2, 'name': '黄金项链 999', 'price': 36800, 'category': '黄金'},
    {'id': 3, 'name': '黄金戒指 999', 'price': 22800, 'category': '黄金'},
    {'id': 4, 'name': '钻戒 50分', 'price': 358000, 'category': '钻石'},
    {'id': 5, 'name': '钻戒 30分', 'price': 188000, 'category': '钻石'},
    {'id': 6, 'name': '翡翠吊坠', 'price': 128000, 'category': '翡翠'},
    {'id': 7, 'name': '银手链', 'price': 1280, 'category': '银饰'},
    {'id': 8, 'name': '银戒指', 'price': 680, 'category': '银饰'},
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder ?? const RetailOrder();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            // 搜索栏
            Container(
              padding: const EdgeInsets.all(12),
              color: CupertinoColors.systemGroupedBackground,
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: '搜索商品名称/编码',
              ),
            ),

            // 分类选择
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
                    onTap: () => setState(() => _selectedCategoryIndex = index),
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

            // 商品网格
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _ProductCard(
                    name: product['name'],
                    price: product['price'],
                    onAdd: () {
                      final item = ProductItem(
                        productID: product['id'],
                        productName: product['name'],
                        price: product['price'],
                        quantity: 1,
                        discountPrice: product['price'],
                        totalDiscountPrice: product['price'],
                      );
                      _addToCart(item);
                    },
                  );
                },
              ),
            ),

            // 底部购物车栏
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