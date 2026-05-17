import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/retail_order_model.dart';

/// 订单确认页
class RetailConfirmPage extends StatefulWidget {
  final RetailOrder order;

  const RetailConfirmPage({super.key, required this.order});

  @override
  State<RetailConfirmPage> createState() => _RetailConfirmPageState();
}

class _RetailConfirmPageState extends State<RetailConfirmPage> {
  late RetailOrder _order;
  final TextEditingController _remarksController = TextEditingController();
  int _useCoins = 0; // 使用积分
  int _useCouponCount = 0; // 使用优惠券数量

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _remarksController.text = _order.remarks ?? '';
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  double get _productsTotalYuan => _order.productsTotalYuan;

  double get _coinDiscountYuan => _useCoins / 100;

  double get _couponDiscountYuan => _useCouponCount * 10 / 100; // 假设每张券抵10元

  double get _actualPayYuan {
    return _productsTotalYuan - _coinDiscountYuan - _couponDiscountYuan;
  }

  void _goToPayment() {
    final order = _order.copyWith(
      decreaseCoins: _useCoins,
      remarks: _remarksController.text.trim(),
    );
    context.push('/order/retail/payment', extra: order);
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
            // 商品列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 会员信息
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
                            const Icon(CupertinoIcons.person_fill, color: CupertinoColors.activeGreen),
                            const SizedBox(width: 8),
                            Text(_order.customerName!),
                            if (_order.customerIdent != null)
                              Text(
                                ' (ID: ${_order.customerIdent})',
                                style: const TextStyle(color: CupertinoColors.secondaryLabel),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 商品列表
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
                                  ? const Border(bottom: BorderSide(color: CupertinoColors.separator))
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
                                  child: const Icon(CupertinoIcons.cube_box, color: CupertinoColors.systemGrey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'x${product.quantity}',
                                        style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(product.totalPriceYuan),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 优惠抵扣
                  _buildSection(
                    title: '优惠抵扣',
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // 积分抵扣
                          if (_order.customerIdent != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.star_fill, color: Color(0xFFFFB300)),
                                  const SizedBox(width: 8),
                                  const Expanded(child: Text('积分抵扣')),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _showCoinPicker(),
                                    child: Row(
                                      children: [
                                        Text(
                                          _useCoins > 0 ? '-${currencyFormat.format(_coinDiscountYuan)}' : '使用',
                                          style: const TextStyle(color: CupertinoColors.activeBlue),
                                        ),
                                        const Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.activeBlue),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 优惠券
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.ticket_fill, color: Color(0xFFFF6B35)),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('优惠券')),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showCouponPicker(),
                                  child: Row(
                                    children: [
                                      Text(
                                        _useCouponCount > 0 ? '已选 $_useCouponCount 张' : '选择',
                                        style: const TextStyle(color: CupertinoColors.activeBlue),
                                      ),
                                      const Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.activeBlue),
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

                  // 备注
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

            // 底部汇总
            Container(
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
                    if (_coinDiscountYuan > 0 || _couponDiscountYuan > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('优惠抵扣', style: TextStyle(color: CupertinoColors.activeGreen)),
                            Text(
                              '-${currencyFormat.format(_coinDiscountYuan + _couponDiscountYuan)}',
                              style: const TextStyle(color: CupertinoColors.activeGreen),
                            ),
                          ],
                        ),
                      ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('应付金额', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(
                          currencyFormat.format(_actualPayYuan > 0 ? _actualPayYuan : 0),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: CupertinoColors.destructiveRed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _actualPayYuan > 0 ? _goToPayment : null,
                        child: const Text('去收款', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
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

  void _showCoinPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.separator))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(padding: EdgeInsets.zero, child: const Text('取消'), onPressed: () => Navigator.pop(ctx)),
                  const Text('积分抵扣', style: TextStyle(fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() => _useCoins = index * 100); // 每次使用100积分
                },
                children: List.generate(
                  21,
                  (index) => Center(child: Text('${index * 100} 积分 (可抵扣 ¥${index})')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCouponPicker() {
    context.push('/order/retail/coupon-select', extra: {
      'order': _order,
      'onSelected': (couponCount, discount) {
        setState(() {
          _useCouponCount = couponCount;
        });
      },
    });
  }
}