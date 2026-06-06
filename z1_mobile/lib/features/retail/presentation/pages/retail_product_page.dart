import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/retail_order_model.dart';
import '../../data/models/cart_item_model.dart';
import '../bloc/product_select_bloc.dart';
import 'product_tab.dart';
import 'service_tab.dart';

class RetailProductPage extends StatefulWidget {
  final RetailOrder? initialOrder;

  const RetailProductPage({super.key, this.initialOrder});

  @override
  State<RetailProductPage> createState() => _RetailProductPageState();
}

class _RetailProductPageState extends State<RetailProductPage> {
  late RetailOrder _order;
  int _selectedTabIndex = 0;
  final List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder ?? const RetailOrder();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
  }

  int get _cartTotalQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get _cartTotalYuan => _cartItems.fold(0, (sum, item) => sum + item.subtotal) / 100;

  /// 商品购物车变更回调：用商品页最新选择整体替换购物车里的商品项，保留服务项。
  void _onGoodsCartChanged(List<CartSkuItem> items) {
    if (!mounted) return;
    setState(() {
      final serviceItems =
          _cartItems.where((i) => i.type == CartItemType.service).toList();
      final goodsItems = items
          .map((item) => CartItem.fromGoodsSku(item.sku, quantity: item.quantity))
          .toList();
      _cartItems
        ..clear()
        ..addAll([...serviceItems, ...goodsItems]);
    });
  }

  /// 服务购物车变更回调：用服务页最新选择整体替换购物车里的服务项，保留商品项。
  void _onServiceCartChanged(List<CartItem> items) {
    if (!mounted) return;
    setState(() {
      final goodsItems =
          _cartItems.where((i) => i.type == CartItemType.goods).toList();
      final serviceItems = items.where((item) => item.name.isNotEmpty).toList();
      _cartItems
        ..clear()
        ..addAll([...goodsItems, ...serviceItems]);
    });
  }

  void _goToConfirm() {
    if (_cartItems.isEmpty) {
      _showError('请先添加商品或服务');
      return;
    }
    // 后端 sale-shop-add 拒绝 customerIdent=0，必须先绑定会员
    if (_order.customerIdent == null || _order.customerIdent == 0) {
      _showError('请先返回上一步绑定会员后再结算');
      return;
    }

    final products = _cartItems.map((item) {
      // 服务项后端要求 type=2 且必传 serviceID；实物项 type=1。
      final isService = item.type == CartItemType.service;
      return ProductItem(
        productID: item.id,
        productName: item.name,
        price: item.price,
        quantity: item.quantity,
        discountPrice: item.price,
        totalDiscountPrice: item.subtotal,
        type: isService ? 2 : 1,
        serviceID: isService ? item.id : null,
      );
    }).toList();

    context.push(
      '/home/retail/confirm',
      extra: _order.copyWith(products: products),
    );
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
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 44,
              color: CupertinoColors.white,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabChanged(0),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTabIndex == 0
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '商品',
                          style: TextStyle(
                            color: _selectedTabIndex == 0
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.label,
                            fontWeight: _selectedTabIndex == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 20, color: CupertinoColors.separator),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabChanged(1),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTabIndex == 1
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '服务',
                          style: TextStyle(
                            color: _selectedTabIndex == 1
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.label,
                            fontWeight: _selectedTabIndex == 1
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedTabIndex == 0
                  ? ProductTab(onCartChanged: _onGoodsCartChanged)
                  : ServiceTab(onCartChanged: _onServiceCartChanged),
            ),
            if (_cartTotalQuantity > 0)
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
                      onTap: () => _showCartSheet(context),
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
                            Text('$_cartTotalQuantity', style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
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
                          Text(currencyFormat.format(_cartTotalYuan), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  void _showCartSheet(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final goodsItems = _cartItems.where((i) => i.type == CartItemType.goods).toList();
    final serviceItems = _cartItems.where((i) => i.type == CartItemType.service).toList();

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
                  Text('购物车 ($_cartTotalQuantity件)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      if (goodsItems.isNotEmpty)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(24, 24),
                          child: const Text('清空商品', style: TextStyle(fontSize: 13)),
                          onPressed: () {
                            setState(() {
                              _cartItems.removeWhere((i) => i.type == CartItemType.goods);
                            });
                          },
                        ),
                      if (goodsItems.isNotEmpty && serviceItems.isNotEmpty)
                        const Text(' | ', style: TextStyle(color: CupertinoColors.separator)),
                      if (serviceItems.isNotEmpty)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(24, 24),
                          child: const Text('清空服务', style: TextStyle(fontSize: 13)),
                          onPressed: () {
                            setState(() {
                              _cartItems.removeWhere((i) => i.type == CartItemType.service);
                            });
                          },
                        ),
                      if (_cartItems.isNotEmpty)
                        CupertinoButton(
                          padding: const EdgeInsets.only(left: 12),
                          minimumSize: const Size(24, 24),
                          child: const Text('清空', style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 13)),
                          onPressed: () {
                            setState(() => _cartItems.clear());
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _cartItems.isEmpty
                  ? const Center(child: Text('购物车为空'))
                  : ListView(
                      children: [
                        if (goodsItems.isNotEmpty) ...[
                          _buildCartSection('商品', goodsItems, currencyFormat),
                        ],
                        if (serviceItems.isNotEmpty) ...[
                          _buildCartSection('服务', serviceItems, currencyFormat),
                        ],
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合计: ${currencyFormat.format(_cartTotalYuan)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildCartSection(String title, List<CartItem> items, NumberFormat formatter) {
    final price = items.fold(0, (sum, item) => sum + item.subtotal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title（${items.length}件）',
                style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w600),
              ),
              Text(
                formatter.format(price / 100),
                style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
              ),
            ],
          ),
        ),
        ...items.map((item) => _CartItemTile(item: item, formatter: formatter, onDelete: () {
          setState(() => _cartItems.remove(item));
        })),
      ],
    );
  }
}

/// 购物车商品项组件
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final NumberFormat formatter;
  final VoidCallback onDelete;

  const _CartItemTile({
    required this.item,
    required this.formatter,
    required this.onDelete,
  });

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
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (item.specName != null)
                  Text(item.specName!, style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${formatter.format(item.price / 100)} x ${item.quantity}',
                  style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(formatter.format(item.subtotal / 100), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(CupertinoIcons.trash, size: 18, color: CupertinoColors.destructiveRed),
          ),
        ],
      ),
    );
  }
}