import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_model.dart';

class SkuSelectModal extends StatefulWidget {
  final SpuModel spu;
  final void Function(SkuModel sku) onAddToCart;
  final void Function(int spuId)? onSelectGoods; // hasSerial=2 时引导到 goods 列表

  const SkuSelectModal({
    super.key,
    required this.spu,
    required this.onAddToCart,
    this.onSelectGoods,
  });

  @override
  State<SkuSelectModal> createState() => _SkuSelectModalState();
}

class _SkuSelectModalState extends State<SkuSelectModal> {
  List<SkuModel> _skus = [];
  int? _selectedIndex;
  bool _isLoading = true;
  String? _error;
  int? _hasSerial; // 1=无序列号，2=有序列号
  final _quantityController = TextEditingController(text: '1');
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dataSource = GetIt.instance<ProductRemoteDataSource>();

      // 并行加载 SKU 和 hasSerial
      final skuFuture = dataSource.getSkuBySpu(widget.spu.spuId);
      final skuBaseFuture = dataSource.getSkuSelectBase();

      if (!mounted) return;

      final skuResult = await skuFuture;
      final skuBaseResult = await skuBaseFuture;

      // 处理 SKU 结果
      List<SkuModel> skus = widget.spu.skus;
      if (skuResult.isSuccess && skuResult.value != null && skuResult.value!.isNotEmpty) {
        skus = skuResult.value!;
      }

      // 处理 hasSerial 结果：从 /sku/select-base 返回的数据中查找当前 SPU 的 hasSerial
      int? hasSerial;
      if (skuBaseResult.isSuccess && skuBaseResult.value != null) {
        for (final category in skuBaseResult.value!.categories) {
          for (final spu in category.spus) {
            if (spu.spuId == widget.spu.spuId) {
              hasSerial = spu.hasSerial;
              break;
            }
          }
          if (hasSerial != null) break;
        }
      }

      setState(() {
        _skus = skus;
        _hasSerial = hasSerial;
        _isLoading = false;
        if (_skus.isNotEmpty) {
          _selectedIndex = 0;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _skus = widget.spu.skus;
        if (_skus.isNotEmpty) {
          _selectedIndex = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final selectedSku = _selectedIndex != null && _selectedIndex! < _skus.length
        ? _skus[_selectedIndex!]
        : null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
            ),
            child: Row(
              children: [
                if (widget.spu.image != null)
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: CupertinoColors.systemGrey6,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.spu.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        CupertinoIcons.cube_box,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.spu.spuName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedSku != null
                            ? currencyFormat.format(selectedSku.price / 100)
                            : widget.spu.priceDisplay,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : _error != null && _skus.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: CupertinoColors.destructiveRed)),
                            const SizedBox(height: 12),
                            CupertinoButton(
                              onPressed: _loadData,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : _skus.isEmpty
                        ? const Center(child: Text('暂无可选规格'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Serial number warning
                                if (_hasSerial == 2) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.exclamationmark_triangle,
                                          color: Color(0xFFFF9800),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '该商品需要序列号',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFE65100),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '请点击下方按钮选择具体商品',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: const Color(0xFFE65100).withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // SKU specs section
                                const Text(
                                  '选择规格',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(_skus.length, (index) {
                                    final sku = _skus[index];
                                    final isSelected = index == _selectedIndex;
                                    final isOutOfStock = (sku.stock ?? 0) <= 0;

                                    return GestureDetector(
                                      onTap: isOutOfStock
                                          ? null
                                          : () => setState(() => _selectedIndex = index),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOutOfStock
                                              ? CupertinoColors.systemGrey5
                                              : isSelected
                                                  ? CupertinoColors.activeBlue
                                                  : CupertinoColors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isOutOfStock
                                                ? CupertinoColors.systemGrey4
                                                : isSelected
                                                    ? CupertinoColors.activeBlue
                                                    : CupertinoColors.systemGrey4,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _getSpecDisplayName(sku),
                                              style: TextStyle(
                                                color: isOutOfStock
                                                    ? CupertinoColors.systemGrey
                                                    : isSelected
                                                        ? CupertinoColors.white
                                                        : CupertinoColors.label,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              currencyFormat.format(sku.price / 100),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isOutOfStock
                                                    ? CupertinoColors.systemGrey2
                                                    : isSelected
                                                        ? CupertinoColors.white.withValues(alpha: 0.8)
                                                        : CupertinoColors.secondaryLabel,
                                              ),
                                            ),
                                            if (isOutOfStock)
                                              const Text(
                                                '缺货',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: CupertinoColors.systemGrey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),

                                // Stock info
                                if (selectedSku != null && _hasSerial != 2) ...[
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      const Text(
                                        '库存：',
                                        style: TextStyle(
                                          color: CupertinoColors.secondaryLabel,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${selectedSku.stock ?? 0} 件',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                // Quantity selector (only for non-serial products)
                                if (_hasSerial != 2) ...[
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      const Text(
                                        '数量',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: CupertinoColors.label,
                                        ),
                                      ),
                                      const Spacer(),
                                      _QuantitySelector(
                                        quantity: _quantity,
                                        maxQuantity: selectedSku?.stock ?? 999,
                                        onChanged: (qty) {
                                          setState(() {
                                            _quantity = qty;
                                            _quantityController.text = qty.toString();
                                          });
                                        },
                                        controller: _quantityController,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
          ),

          // Bottom button
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
                child: _hasSerial == 2
                    ? CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          // 关闭弹窗并引导到 goods 列表
                          Navigator.pop(context);
                          widget.onSelectGoods?.call(widget.spu.spuId);
                        },
                        child: const Text('选择具体商品'),
                      )
                    : CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(12),
                        onPressed: selectedSku != null && (selectedSku.stock ?? 0) > 0
                            ? () {
                                widget.onAddToCart(selectedSku);
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          selectedSku != null && (selectedSku.stock ?? 0) > 0
                              ? '加入购物车'
                              : '暂无可选商品',
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取规格显示名称（从 specs 或 skuName 中提取）
  String _getSpecDisplayName(SkuModel sku) {
    // 优先从 specs 中提取颜色或其他规格
    if (sku.specs != null && sku.specs!.isNotEmpty) {
      final specs = sku.specs!;
      // 常见规格字段
      final color = specs['color'] ?? specs['颜色'] ?? specs['colour'];
      final memory = specs['memory'] ?? specs['内存'] ?? specs['ram'];
      final storage = specs['storage'] ?? specs['存储'] ?? specs['rom'];

      final parts = <String>[];
      if (color != null && color.toString().isNotEmpty) parts.add(color.toString());
      if (memory != null && memory.toString().isNotEmpty) parts.add(memory.toString());
      if (storage != null && storage.toString().isNotEmpty) parts.add(storage.toString());

      if (parts.isNotEmpty) return parts.join(' / ');
    }

    // 备用：从 skuName 提取
    return sku.skuName;
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final TextEditingController controller;

  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: quantity > 1
                ? () => onChanged(quantity - 1)
                : null,
            child: const Icon(CupertinoIcons.minus, size: 18),
          ),
          SizedBox(
            width: 50,
            child: CupertinoTextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const BoxDecoration(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              onChanged: (value) {
                final qty = int.tryParse(value);
                if (qty != null && qty > 0 && qty <= maxQuantity) {
                  onChanged(qty);
                }
              },
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
            child: const Icon(CupertinoIcons.plus, size: 18),
          ),
        ],
      ),
    );
  }
}
