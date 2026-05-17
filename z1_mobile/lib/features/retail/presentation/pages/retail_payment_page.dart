import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/models/retail_order_model.dart';

/// 收款页
class RetailPaymentPage extends StatefulWidget {
  final RetailOrder order;

  const RetailPaymentPage({super.key, required this.order});

  @override
  State<RetailPaymentPage> createState() => _RetailPaymentPageState();
}

class _RetailPaymentPageState extends State<RetailPaymentPage> {
  late RetailOrder _order;
  final Map<int, int> _selectedPayments = {}; // method -> amount (分)
  final TextEditingController _cashController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  double get _actualPayYuan => _order.actualPayYuan;

  double get _paidYuan => _selectedPayments.values.fold<int>(0, (sum, v) => sum + v) / 100;

  double get _remainingYuan {
    final remaining = _actualPayYuan - _paidYuan;
    return remaining > 0 ? remaining : 0;
  }

  double get _changeYuan {
    final change = _paidYuan - _actualPayYuan;
    return change > 0 ? change : 0;
  }

  bool get _canComplete => _remainingYuan <= 0 && !_isProcessing && _selectedPayments.isNotEmpty;

  void _selectPaymentMethod(PayMethod method, int amount) {
    setState(() {
      _selectedPayments[method.id] = amount;
    });
  }

  void _showCashInput() {
    _cashController.clear();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('输入现金金额'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: _cashController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            placeholder: '输入金额',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () {
              final amount = double.tryParse(_cashController.text);
              if (amount != null && amount > 0) {
                _selectPaymentMethod(PayMethod.cash, (amount * 100).toInt());
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _completePayment() async {
    if (!_canComplete) return;

    setState(() => _isProcessing = true);

    try {
      final dio = getIt<Dio>();
      final response = await dio.post(
        '/order/shop-sale/add',
        data: {
          'warehouseID': _order.warehouseID,
          'customerIdent': _order.customerIdent,
          'sellerIdent': _order.sellerIdent,
          'productInfos': _order.products.map((p) => {
            'productID': p.productID,
            'price': p.discountPrice > 0 ? p.discountPrice : p.price,
            'quantity': p.quantity,
            'type': p.type,
            'isGift': p.isGift,
          }).toList(),
          'payMode': _selectedPayments.entries.map((e) => {
            'method': e.key,
            'amount': e.value,
          }).toList(),
          if (_order.remarks != null) 'remarks': _order.remarks,
        },
      );

      final orderNumber = response.data['orderNumber'] ?? 'Z1-${DateTime.now().millisecondsSinceEpoch}';

      final payments = _selectedPayments.entries
          .map((e) => PayItem(method: e.key, amount: e.value))
          .toList();

      final completedOrder = _order.copyWith(
        orderNumber: orderNumber,
        payments: payments,
        status: RetailOrderStatus.paid,
      );

      if (mounted) {
        context.pushReplacement('/order/retail/complete', extra: completedOrder);
      }
    } catch (e) {
      if (mounted) {
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('创建订单失败'),
            content: Text('${e}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('收款'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 金额显示
            Container(
              padding: const EdgeInsets.all(24),
              color: CupertinoColors.white,
              child: Column(
                children: [
                  const Text(
                    '应收金额',
                    style: TextStyle(color: CupertinoColors.secondaryLabel),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(_actualPayYuan),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                  if (_paidYuan > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('已付: ', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                        Text(
                          currencyFormat.format(_paidYuan),
                          style: const TextStyle(color: CupertinoColors.activeGreen, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (_remainingYuan > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('还需: ', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                            Text(
                              currencyFormat.format(_remainingYuan),
                              style: const TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    if (_changeYuan > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('找零: ', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                            Text(
                              currencyFormat.format(_changeYuan),
                              style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 支付方式
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    '选择支付方式',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _PayMethodCard(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        label: '现金',
                        color: const Color(0xFF4CAF50),
                        isSelected: _selectedPayments.containsKey(1),
                        onTap: _showCashInput,
                      ),
                      _PayMethodCard(
                        icon: CupertinoIcons.chat_bubble_text_fill,
                        label: '微信',
                        color: const Color(0xFF07C160),
                        isSelected: _selectedPayments.containsKey(2),
                        onTap: () => _selectPaymentMethod(PayMethod.wechat, (_remainingYuan * 100).toInt()),
                      ),
                      _PayMethodCard(
                        icon: CupertinoIcons.creditcard_fill,
                        label: '支付宝',
                        color: const Color(0xFF1677FF),
                        isSelected: _selectedPayments.containsKey(3),
                        onTap: () => _selectPaymentMethod(PayMethod.alipay, (_remainingYuan * 100).toInt()),
                      ),
                      _PayMethodCard(
                        icon: CupertinoIcons.creditcard,
                        label: '银行卡',
                        color: const Color(0xFF8B4513),
                        isSelected: _selectedPayments.containsKey(4),
                        onTap: () => _selectPaymentMethod(PayMethod.bankCard, (_remainingYuan * 100).toInt()),
                      ),
                    ],
                  ),

                  // 已选支付方式列表
                  if (_selectedPayments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '已选支付',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _selectedPayments.entries.map((entry) {
                          final method = PayMethod.values.firstWhere((m) => m.id == entry.key, orElse: () => PayMethod.cash);
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
                            ),
                            child: Row(
                              children: [
                                Text(_getMethodLabel(method), style: const TextStyle(fontWeight: FontWeight.w500)),
                                const Spacer(),
                                Text(
                                  currencyFormat.format(entry.value / 100),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 24,
                                  child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.systemGrey),
                                  onPressed: () {
                                    setState(() => _selectedPayments.remove(entry.key));
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 完成按钮
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
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _canComplete ? _completePayment : null,
                  child: _isProcessing
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : const Text('完成收款', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodLabel(PayMethod method) {
    switch (method) {
      case PayMethod.cash:
        return '现金';
      case PayMethod.wechat:
        return '微信';
      case PayMethod.alipay:
        return '支付宝';
      case PayMethod.bankCard:
        return '银行卡';
    }
  }
}

class _PayMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PayMethodCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : CupertinoColors.separator,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : CupertinoColors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected)
              const Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.activeGreen, size: 16),
          ],
        ),
      ),
    );
  }
}