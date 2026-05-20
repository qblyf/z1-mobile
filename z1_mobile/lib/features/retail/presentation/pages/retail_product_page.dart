import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/retail_order_model.dart';
import '../../data/models/product_model.dart';
import '../bloc/product_select_bloc.dart';
import '../bloc/service_bloc.dart';
import 'product_tab.dart';

class RetailProductPage extends StatefulWidget {
  final RetailOrder? initialOrder;

  const RetailProductPage({super.key, this.initialOrder});

  @override
  State<RetailProductPage> createState() => _RetailProductPageState();
}

class _RetailProductPageState extends State<RetailProductPage> {
  late RetailOrder _order;
  int _selectedTabIndex = 0;
  final List<CartSkuItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder ?? const RetailOrder();
    context.read<ServiceBloc>().add(const ServiceLoadRequested());
  }

void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    _selectedCategoryIndex = 0;
    if (index == 0) {
      context.read<ProductBloc>().add(const ProductLoadRequested());
    } else {
      context.read<ServiceBloc>().add(const ServiceLoadRequested());
    }
  }

  void _onCategoryChanged(int index, List<CategoryModel> categories) {
    setState(() => _selectedCategoryIndex = index);
    final category = index == 0 ? null : categories[index - 1].name;
    context.read<ProductBloc>().add(ProductCategoryChanged(category ?? '全部'));
  }

  void _onServiceCategoryChanged(int index, List<ServiceCategoryModel> categories) {
    setState(() => _selectedCategoryIndex = index);
    final category = index == 0 ? null : categories[index - 1].name;
    context.read<ServiceBloc>().add(ServiceCategoryChanged(category));
  }

  List<ProductItem> get _currentCart => _selectedTabIndex == 0 ? _cartGoods : _cartServices;

  double get _cartTotalYuan {
    final goodsTotal = _cartGoods.fold<int>(0, (sum, p) => sum + p.totalDiscountPrice);
    final servicesTotal = _cartServices.fold<int>(0, (sum, p) => sum + p.totalDiscountPrice);
    return (goodsTotal + servicesTotal) / 100;
  }

  int get _cartTotalQuantity {
    return _cartGoods.fold<int>(0, (sum, p) => sum + p.quantity) +
        _cartServices.fold<int>(0, (sum, p) => sum + p.quantity);
  }

  void _addToCart(ProductModel product) {
    final cart = _selectedTabIndex == 0 ? _cartGoods : _cartServices;
    setState(() {
      final existing = cart.indexWhere((p) => p.productID == product.productID);
      if (existing >= 0) {
        final p = cart[existing];
        cart[existing] = p.copyWith(
          quantity: p.quantity + 1,
          totalDiscountPrice: p.discountPrice * (p.quantity + 1),
        );
      } else {
        cart.add(ProductItem(
          productID: product.productID,
          productName: product.productName,
          price: product.price,
          quantity: 1,
          discountPrice: product.price,
          totalDiscountPrice: product.price,
        ));
      }
    });
  }

  void _addServiceToCart(ServiceModel service) {
    setState(() {
      final existing = _cartServices.indexWhere((p) => p.productID == service.id);
      if (existing >= 0) {
        final p = _cartServices[existing];
        _cartServices[existing] = p.copyWith(
          quantity: p.quantity + 1,
          totalDiscountPrice: p.discountPrice * (p.quantity + 1),
        );
      } else {
        _cartServices.add(ProductItem(
          productID: service.id,
          productName: service.name,
          price: service.price,
          quantity: 1,
          discountPrice: service.price,
          totalDiscountPrice: service.price,
        ));
      }
    });
  }

  void _onCartChanged(List<CartSkuItem> items) {
    setState(() {
      _cartItems.clear();
      _cartItems.addAll(items);
    });
  }

  double get _cartTotalYuan {
    return _cartItems.fold<int>(0, (sum, item) => sum + item.subtotal) / 100;
  }

  int get _cartTotalQuantity {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void _goToConfirm() {
    if (_cartItems.isEmpty) {
      _showError('请先添加商品');
      return;
    }
    context.push('/home/retail/confirm', extra: _order);
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
                  ? ProductTab(onCartChanged: _onCartChanged)
                  : const Center(child: Text('服务 Tab 待实现')),
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
                    Container(
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
}