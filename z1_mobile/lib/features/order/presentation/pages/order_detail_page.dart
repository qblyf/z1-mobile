import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_product_model.dart';
import '../bloc/order_detail_bloc.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderNumber;
  const OrderDetailPage({super.key, required this.orderNumber});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final OrderDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<OrderDetailBloc>();
    _bloc.add(OrderDetailLoadRequested(widget.orderNumber));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('订单详情'),
          previousPageTitle: '返回',
        ),
        child: SafeArea(
          child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              if (state is OrderDetailLoading) {
                return const Center(child: CupertinoActivityIndicator());
              }

              if (state is OrderDetailError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        child: const Text('重试'),
                        onPressed: () => _bloc.add(
                          OrderDetailLoadRequested(widget.orderNumber),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is OrderDetailLoaded) {
                return _buildContent(state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(OrderDetailLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderInfo(state.order, currencyFormat),
        const SizedBox(height: 16),
        _buildProductList(state.products, currencyFormat),
        const SizedBox(height: 16),
        _buildSummary(state, currencyFormat),
      ],
    );
  }

  Widget _buildOrderInfo(OrderModel order, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '订单信息',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusEnum == OrderStatus.completed
                      ? const Color(0xFFDCFCE7)
                      : order.statusEnum == OrderStatus.refunded
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFE0EDFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: order.statusEnum == OrderStatus.completed
                        ? const Color(0xFF16A34A)
                        : order.statusEnum == OrderStatus.refunded
                            ? const Color(0xFFDC2626)
                            : CupertinoColors.activeBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('订单号', order.orderNumber),
          _buildInfoRow(
            '下单时间',
            DateFormat('yyyy-MM-dd HH:mm').format(
              DateTime.fromMillisecondsSinceEpoch(order.createdAt * 1000),
            ),
          ),
          _buildInfoRow(
            '客户',
            order.customerName.isEmpty ? '散客' : order.customerName,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: CupertinoColors.secondaryLabel),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildProductList(
      List<OrderProductModel> products, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品明细 (${products.length}件)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...products.map((product) =>
              _ProductItem(product: product, currencyFormat: currencyFormat)),
        ],
      ),
    );
  }

  Widget _buildSummary(OrderDetailLoaded state, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('商品总数'),
              Text('${state.totalQuantity}件'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '订单金额',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                currencyFormat.format(state.order.finalAmountYuan),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final OrderProductModel product;
  final NumberFormat currencyFormat;

  const _ProductItem({required this.product, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text('📦', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'x$quantity · ¥${product.unitPriceYuan.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(product.finalPriceYuan),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  int get quantity => product.quantity;
}
