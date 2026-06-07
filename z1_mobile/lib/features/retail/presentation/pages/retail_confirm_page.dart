import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/retail_order_model.dart';
import '../../data/models/coupon_model.dart';
import '../bloc/coin_discount_bloc.dart';

class RetailConfirmPage extends StatefulWidget {
  final RetailOrder order;

  const RetailConfirmPage({super.key, required this.order});

  @override
  State<RetailConfirmPage> createState() => _RetailConfirmPageState();
}

class _RetailConfirmPageState extends State<RetailConfirmPage> {
  late RetailOrder _order;
  final TextEditingController _remarksController = TextEditingController();
  int _useCouponCount = 0;
  int _couponDiscount = 0;
  List<CouponModel> _selectedCoupons = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _remarksController.text = _order.remarks ?? '';
    if (_order.customerIdent != null) {
      final orderAmount = (_order.productsTotalYuan * 100).toInt();
      context.read<CoinDiscountBloc>().add(CoinDiscountLoadRequested(
            customerIdent: _order.customerIdent!,
            orderAmount: orderAmount,
          ));
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  double get _productsTotalYuan => _order.productsTotalYuan;

  double get _couponDiscountYuan => _couponDiscount / 100;

  void _goToPayment() {
    final coinState = context.read<CoinDiscountBloc>().state;
    final decreaseCoins =
        coinState is CoinDiscountLoaded ? coinState.selectedCoins : 0;

    // 把已选优惠券（CouponModel）转换为接口需要的 CouponItem 列表
    final couponItems = _selectedCoupons
        .map((c) => CouponItem(couponId: c.couponId, amount: c.discountValue))
        .toList();

    final order = _order.copyWith(
      decreaseCoins: decreaseCoins,
      coupons: couponItems,
      remarks: _remarksController.text.trim(),
    );
    context.push('/home/retail/payment', extra: order);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('订单确认'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_order.customerName != null)
                    _buildSection(
                      title: '会员信息',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.person_fill,
                                color: CupertinoColors.activeGreen),
                            const SizedBox(width: 8),
                            Text(_order.customerName!),
                            if (_order.customerIdent != null)
                              Text(
                                ' (ID: ${_order.customerIdent})',
                                style: const TextStyle(
                                    color: CupertinoColors.secondaryLabel),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: '商品清单',
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _order.products.asMap().entries.map((entry) {
                          final index = entry.key;
                          final product = entry.value;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: index < _order.products.length - 1
                                  ? const Border(
                                      bottom: BorderSide(
                                          color: CupertinoColors.separator))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(CupertinoIcons.cube_box,
                                      color: CupertinoColors.systemGrey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.productName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'x${product.quantity}',
                                        style: const TextStyle(
                                            color:
                                                CupertinoColors.secondaryLabel,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(product.totalPriceYuan),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: '优惠抵扣',
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (_order.customerIdent != null)
                            BlocBuilder<CoinDiscountBloc, CoinDiscountState>(
                              builder: (context, state) {
                                if (state is CoinDiscountLoading) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  CupertinoColors.separator)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(CupertinoIcons.star_fill,
                                            color: Color(0xFFFFB300)),
                                        SizedBox(width: 8),
                                        Text('积分抵扣'),
                                        SizedBox(width: 12),
                                        CupertinoActivityIndicator(radius: 8),
                                      ],
                                    ),
                                  );
                                }
                                if (state is CoinDiscountLoaded) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  CupertinoColors.separator)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(CupertinoIcons.star_fill,
                                            color: Color(0xFFFFB300)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('积分抵扣'),
                                              Text(
                                                '可用 ${state.availableCoins} 积分',
                                                style: const TextStyle(
                                                  color: CupertinoColors
                                                      .secondaryLabel,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _showCoinPicker(
                                              state.availableCoins),
                                          child: Row(
                                            children: [
                                              Text(
                                                state.selectedCoins > 0
                                                    ? '-${currencyFormat.format(state.discountAmount / 100)}'
                                                    : '使用',
                                                style: const TextStyle(
                                                    color: CupertinoColors
                                                        .activeBlue),
                                              ),
                                              const Icon(
                                                  CupertinoIcons.chevron_right,
                                                  size: 16,
                                                  color: CupertinoColors
                                                      .activeBlue),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                if (state is CoinDiscountError) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  CupertinoColors.separator)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(CupertinoIcons.star_fill,
                                            color: Color(0xFFFFB300)),
                                        SizedBox(width: 8),
                                        Expanded(child: Text('积分抵扣')),
                                        Text(
                                          '加载失败',
                                          style: TextStyle(
                                            color:
                                                CupertinoColors.destructiveRed,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.ticket_fill,
                                    color: Color(0xFFFF6B35)),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('优惠券')),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showCouponPicker(),
                                  child: Row(
                                    children: [
                                      Text(
                                        _useCouponCount > 0
                                            ? '已选 $_useCouponCount 张 (-¥${(_couponDiscount / 100).toStringAsFixed(2)})'
                                            : '选择',
                                        style: const TextStyle(
                                            color: CupertinoColors.activeBlue),
                                      ),
                                      const Icon(CupertinoIcons.chevron_right,
                                          size: 16,
                                          color: CupertinoColors.activeBlue),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: '订单备注',
                    child: CupertinoTextField(
                      controller: _remarksController,
                      placeholder: '可输入订单备注信息',
                      maxLines: 3,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<CoinDiscountBloc, CoinDiscountState>(
              builder: (context, coinState) {
                final coinDiscountYuan = coinState is CoinDiscountLoaded
                    ? coinState.discountAmount / 100
                    : 0.0;
                final actualPayYuan =
                    _productsTotalYuan - coinDiscountYuan - _couponDiscountYuan;

                return Container(
                  padding: const EdgeInsets.all(16),
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
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('商品总额'),
                            Text(currencyFormat.format(_productsTotalYuan)),
                          ],
                        ),
                        if (coinDiscountYuan > 0 || _couponDiscountYuan > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('优惠抵扣',
                                    style: TextStyle(
                                        color: CupertinoColors.activeGreen)),
                                Text(
                                  '-${currencyFormat.format(coinDiscountYuan + _couponDiscountYuan)}',
                                  style: const TextStyle(
                                      color: CupertinoColors.activeGreen),
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('应付金额',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            Text(
                              currencyFormat.format(
                                  actualPayYuan > 0 ? actualPayYuan : 0),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: CupertinoColors.destructiveRed),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            borderRadius: BorderRadius.circular(12),
                            onPressed: actualPayYuan > 0 ? _goToPayment : null,
                            child: const Text('去收款',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showCoinPicker(int availableCoins) {
    final coinState = context.read<CoinDiscountBloc>().state;
    final currentSelected =
        coinState is CoinDiscountLoaded ? coinState.selectedCoins : 0;
    int tempSelected = currentSelected;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: CupertinoColors.separator))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('取消'),
                      onPressed: () => Navigator.pop(ctx)),
                  const Text('积分抵扣',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('确定'),
                    onPressed: () {
                      final orderAmount =
                          (_order.productsTotalYuan * 100).toInt();
                      context
                          .read<CoinDiscountBloc>()
                          .add(CoinDiscountCalculateRequested(
                            customerIdent: _order.customerIdent!,
                            coins: tempSelected,
                            orderAmount: orderAmount,
                          ));
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: currentSelected ~/ 100,
                ),
                onSelectedItemChanged: (index) {
                  tempSelected = index * 100;
                },
                children: List.generate(
                  (availableCoins ~/ 100) + 1,
                  (index) =>
                      Center(child: Text('${index * 100} 积分 (可抵扣 ¥$index)')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCouponPicker() {
    context.push('/home/retail/coupon-select', extra: {
      'order': _order,
    }).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _useCouponCount = result['couponCount'] ?? 0;
          _couponDiscount = result['discount'] ?? 0;
          _selectedCoupons =
              (result['coupons'] as List<dynamic>?)?.cast<CouponModel>() ?? [];
        });
      }
    });
  }
}
