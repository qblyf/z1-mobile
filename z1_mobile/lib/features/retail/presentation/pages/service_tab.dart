import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/service_model.dart';
import '../../data/models/cart_item_model.dart';
import '../bloc/service_bloc.dart';

class ServiceTab extends StatefulWidget {
  final void Function(List<CartItem> cartItems) onCartChanged;

  const ServiceTab({super.key, required this.onCartChanged});

  @override
  State<ServiceTab> createState() => _ServiceTabState();
}

class _ServiceTabState extends State<ServiceTab> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(const ServiceLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is ServiceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: CupertinoColors.destructiveRed)),
                const SizedBox(height: 12),
                CupertinoButton(
                  child: const Text('重试'),
                  onPressed: () => context.read<ServiceBloc>().add(const ServiceLoadRequested()),
                ),
              ],
            ),
          );
        }
        if (state is ServiceLoaded) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: CupertinoColors.systemGroupedBackground,
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: '搜索服务名称',
                  onChanged: (value) {
                    context.read<ServiceBloc>().add(ServiceSearchChanged(value));
                  },
                ),
              ),
              Container(
                height: 44,
                color: CupertinoColors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.categories.length + 1,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    final label = index == 0 ? '全部' : state.categories[index - 1].name;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryIndex = index);
                        final category = index == 0 ? null : state.categories[index - 1].name;
                        context.read<ServiceBloc>().add(ServiceCategoryChanged(category));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? CupertinoColors.activeBlue : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          label,
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
                child: _buildServiceList(state),
              ),
              if (state.cartTotalQuantity > 0)
                _buildCartBar(context, state),
            ],
          );
        }
        return const Center(child: Text('请搜索服务'));
      },
    );
  }

  Widget _buildServiceList(ServiceLoaded state) {
    if (state.filteredServices.isEmpty) {
      return const Center(child: Text('暂无服务'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.filteredServices.length,
      itemBuilder: (context, index) {
        final service = state.filteredServices[index];
        return _ServiceCard(
          service: service,
          onAddToCart: () {
            context.read<ServiceBloc>().add(ServiceAddedToCart(service: service));
          },
        );
      },
    );
  }

  Widget _buildCartBar(BuildContext context, ServiceLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Container(
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
            onTap: () => _showCartSheet(context, state),
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
                  Text(
                    '${state.cartTotalQuantity}',
                    style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
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
                const Text('合计', style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11)),
                Text(currencyFormat.format(state.cartTotalPrice / 100), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            borderRadius: BorderRadius.circular(20),
            onPressed: () {
              widget.onCartChanged(state.cartItems);
            },
            child: const Text('去结算'),
          ),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context, ServiceLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

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
                  Text('购物车 (${state.cartTotalQuantity}件)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('清空'),
                    onPressed: () {
                      // 健壮可扩展设计：
                      // - 状态检查：确保 BLoC 处于可处理事件的状态
                      // - 防止意外状态转换：仅在 ServiceLoaded 状态下允许清空购物车
                      // - 时序保证：避免在状态过渡期间发送事件
                      final bloc = context.read<ServiceBloc>();
                      if (bloc.state is ServiceLoaded) {
                        bloc.add(const ServiceCartCleared());
                      } else {
                        // 非期望状态：静默忽略，不抛出异常影响用户
                        debugPrint('ServiceCartCleared 事件跳过：当前状态 ${bloc.state.runtimeType} 非 ServiceLoaded');
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.cartItems.isEmpty
                  ? const Center(child: Text('购物车为空'))
                  : ListView.builder(
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return _ServiceCartItem(
                          item: item,
                          formatter: currencyFormat,
                          onQuantityChanged: (delta) {
                            if (item.quantity + delta <= 0) {
                              context.read<ServiceBloc>().add(
                                ServiceRemovedFromCart(serviceId: item.id, quantity: item.quantity),
                              );
                            } else {
                              context.read<ServiceBloc>().add(
                                ServiceRemovedFromCart(serviceId: item.id, quantity: -delta),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合计: ${currencyFormat.format(state.cartTotalPrice / 100)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onAddToCart;

  const _ServiceCard({required this.service, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: CupertinoColors.systemGrey.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              service.isGoods ? CupertinoIcons.cube_box : CupertinoIcons.wrench,
              size: 28,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                if (service.shortName != null && service.shortName!.isNotEmpty)
                  Text(service.shortName!, style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(service.price / 100),
                  style: const TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAddToCart,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(CupertinoIcons.plus, color: CupertinoColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCartItem extends StatelessWidget {
  final CartItem item;
  final NumberFormat formatter;
  final Function(int) onQuantityChanged;

  const _ServiceCartItem({
    required this.item,
    required this.formatter,
    required this.onQuantityChanged,
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
                Text(formatter.format(item.price / 100), style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(padding: EdgeInsets.zero, minSize: 28, child: const Icon(CupertinoIcons.minus_circle, size: 22), onPressed: () => onQuantityChanged(-1)),
              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              CupertinoButton(padding: EdgeInsets.zero, minSize: 28, child: const Icon(CupertinoIcons.plus_circle, size: 22), onPressed: () => onQuantityChanged(1)),
            ],
          ),
          const SizedBox(width: 8),
          Text(formatter.format(item.subtotal / 100), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}