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
              // Header
              _buildHeader(state),
              // Search Bar
              _buildSearchBar(context, state),
              // Breadcrumbs
              if (state.viewMode != ServiceViewMode.search) _buildBreadcrumbs(context, state),
              // Content
              Expanded(
                child: _buildContent(context, state),
              ),
              // Cart Bar
              if (state.cartTotalQuantity > 0)
                _buildCartBar(context, state),
            ],
          );
        }
        return const Center(child: Text('请搜索服务'));
      },
    );
  }

  Widget _buildHeader(ServiceLoaded state) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: const Center(
        child: Text(
          '选择服务',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ServiceLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: CupertinoColors.white,
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _searchController,
              placeholder: '搜索服务名称或编号',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(CupertinoIcons.search, color: CupertinoColors.secondaryLabel, size: 18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(18),
              ),
              onChanged: (value) {
                context.read<ServiceBloc>().add(ServiceSearchChanged(value));
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // TODO: Camera scan functionality
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(CupertinoIcons.camera, color: CupertinoColors.secondaryLabel, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, ServiceLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: CupertinoColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < state.breadcrumbs.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(CupertinoIcons.chevron_right, size: 12, color: CupertinoColors.secondaryLabel),
                ),
              GestureDetector(
                onTap: () => context.read<ServiceBloc>().add(ServiceBreadcrumbTapped(i)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: i == state.breadcrumbs.length - 1 
                        ? const Color(0xFFE8F4FF) 
                        : CupertinoColors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    state.breadcrumbs[i].name,
                    style: TextStyle(
                      fontSize: 14,
                      color: i == state.breadcrumbs.length - 1 
                          ? CupertinoColors.activeBlue 
                          : CupertinoColors.secondaryLabel,
                      fontWeight: i == state.breadcrumbs.length - 1 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ServiceLoaded state) {
    if (state.isLoadingServices) {
      return const Center(child: CupertinoActivityIndicator());
    }

    switch (state.viewMode) {
      case ServiceViewMode.search:
        return _buildServiceList(context, state, title: '搜索"${state.searchKeyword}"结果');
      case ServiceViewMode.service:
        return _buildServiceList(context, state, title: '${state.currentCategoryName}服务');
      case ServiceViewMode.category:
        return _buildCategoryList(context, state);
    }
  }

  Widget _buildCategoryList(BuildContext context, ServiceLoaded state) {
    if (state.currentCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.folder_open, size: 48, color: CupertinoColors.systemGrey),
            const SizedBox(height: 12),
            Text(
              state.isRootLevel ? '暂无分类' : '该分类下暂无子分类',
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          ],
        ),
      );
    }

    return Container(
      color: CupertinoColors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.currentCategories.length,
        separatorBuilder: (context, index) => Container(
          height: 1,
          margin: const EdgeInsets.only(left: 16),
          color: CupertinoColors.separator,
        ),
        itemBuilder: (context, index) {
          final category = state.currentCategories[index];
          final hasChildren = (state.categoryChildrenMap[category.id] ?? []).isNotEmpty;

          return GestureDetector(
            onTap: () => context.read<ServiceBloc>().add(ServiceCategoryTapped(category.id)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: CupertinoColors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(fontSize: 14, color: CupertinoColors.label),
                    ),
                  ),
                  if (hasChildren)
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: CupertinoColors.secondaryLabel,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceList(BuildContext context, ServiceLoaded state, {String? title}) {
    if (state.currentServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.wrench, size: 48, color: CupertinoColors.systemGrey),
            const SizedBox(height: 12),
            Text(
              title?.contains('搜索') == true ? '未找到相关服务' : '暂无服务',
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.label,
              ),
            ),
          ),
        Expanded(
          child: Container(
            color: CupertinoColors.systemGroupedBackground,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.currentServices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final service = state.currentServices[index];
                return _ServiceCard(
                  service: service,
                  onAddToCart: () {
                    context.read<ServiceBloc>().add(ServiceAddedToCart(service: service));
                  },
                );
              },
            ),
          ),
        ),
      ],
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
                      context.read<ServiceBloc>().add(const ServiceCartCleared());
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        service.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (service.isGoods) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '热门',
                          style: TextStyle(fontSize: 10, color: Color(0xFFFF9800)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(service.price / 100),
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAddToCart,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(16),
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
              CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.minus_circle, size: 22), onPressed: () => onQuantityChanged(-1)),
              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.plus_circle, size: 22), onPressed: () => onQuantityChanged(1)),
            ],
          ),
          const SizedBox(width: 8),
          Text(formatter.format(item.subtotal / 100), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
