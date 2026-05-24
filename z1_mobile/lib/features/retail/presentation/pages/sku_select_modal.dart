import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../bloc/product_select_bloc.dart';

class SkuSelectModal extends StatefulWidget {
  final SpuModel spu;
  final void Function(SkuModel sku) onAddToCart;

  const SkuSelectModal({
    super.key,
    required this.spu,
    required this.onAddToCart,
  });

  @override
  State<SkuSelectModal> createState() => _SkuSelectModalState();
}

class _SkuSelectModalState extends State<SkuSelectModal> {
  int _selectedSkuIndex = 0;
  final _quantityController = TextEditingController(text: '1');
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // 打开弹窗时，通过 bloc 获取 hasSerial 和库存
    context.read<ProductSelectBloc>().add(ProductSelectSkuModalOpened(widget.spu));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final skus = widget.spu.skus;
    final selectedSku = skus.isNotEmpty ? skus[_selectedSkuIndex] : null;

    // 监听 bloc 状态，获取 hasSerial 和库存
    return BlocBuilder<ProductSelectBloc, ProductSelectState>(
      builder: (context, state) {
        int? hasSerial;
        int? stock;
        bool stockLoading = false;
        bool stockError = false;

        if (state is ProductSelectLoaded) {
          final selectedSpu = state.selectedSpu;
          if (selectedSpu != null && selectedSpu.spuId == widget.spu.spuId) {
            hasSerial = selectedSpu.hasSerial ?? widget.spu.hasSerial;
          }
          // 从 stockMap 获取库存
          final stockMap = state.stockMap;
          if (stockMap.containsKey(widget.spu.spuId)) {
            final s = stockMap[widget.spu.spuId];
            if (s == null) {
              stockLoading = true;
            } else if (s == -1) {
              stockError = true;
            } else {
              stock = s;
            }
          } else {
            stockLoading = true;
          }
        } else {
          stockLoading = true;
        }

        return Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.spu.spuName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          if (hasSerial != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: hasSerial == 1
                                    ? CupertinoColors.systemOrange.withValues(alpha: 0.15)
                                    : CupertinoColors.systemGrey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hasSerial == 1 ? '需序列号' : '无需序列号',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: hasSerial == 1
                                      ? CupertinoColors.systemOrange
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.systemGrey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '规格',
                        style: TextStyle(fontWeight: FontWeight.w500, color: CupertinoColors.secondaryLabel),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(skus.length, (index) {
                          final sku = skus[index];
                          final isSelected = index == _selectedSkuIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSkuIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected ? null : Border.all(color: CupertinoColors.separator),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    sku.skuName,
                                    style: TextStyle(
                                      color: isSelected ? CupertinoColors.white : CupertinoColors.label,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currencyFormat.format(sku.price / 100),
                                    style: TextStyle(
                                      color: isSelected ? CupertinoColors.white.withValues(alpha: 0.8) : CupertinoColors.secondaryLabel,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      if (selectedSku != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              '库存：',
                              style: TextStyle(color: CupertinoColors.secondaryLabel),
                            ),
                            if (stockLoading)
                              const CupertinoActivityIndicator(radius: 6)
                            else if (stockError)
                              const Text(
                                '-',
                                style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.destructiveRed),
                              )
                            else
                              Text(
                                stock?.toString() ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              '数量：',
                              style: TextStyle(color: CupertinoColors.secondaryLabel),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                  _quantityController.text = _quantity.toString();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(CupertinoIcons.minus, size: 18),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: CupertinoTextField(
                                controller: _quantityController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final qty = int.tryParse(value);
                                  if (qty != null && qty > 0) {
                                    setState(() => _quantity = qty);
                                  }
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _quantity++);
                                _quantityController.text = _quantity.toString();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(CupertinoIcons.plus, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(12),
                      onPressed: selectedSku != null
                          ? () {
                              widget.onAddToCart(selectedSku);
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text('加入购物车'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
