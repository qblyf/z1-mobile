import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/service_model.dart';
import '../bloc/service_bloc.dart';

class ServiceTab extends StatefulWidget {
  final void Function(ServiceModel service) onServiceAdded;

  const ServiceTab({super.key, required this.onServiceAdded});

  @override
  State<ServiceTab> createState() => _ServiceTabState();
}

class _ServiceTabState extends State<ServiceTab> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

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
                  onChanged: (value) {},
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
            ],
          );
        }
        return const Center(child: Text('请选择服务'));
      },
    );
  }

  Widget _buildServiceList(ServiceLoaded state) {
    final services = state.filteredServices;

    if (services.isEmpty) {
      return const Center(child: Text('暂无服务'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _ServiceCard(
          service: service,
          onAdd: () => widget.onServiceAdded(service),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onAdd;

  const _ServiceCard({required this.service, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(CupertinoIcons.wrench, size: 28, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                if (service.shortName != null) ...[
                  const SizedBox(height: 4),
                  Text(service.shortName!, style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currencyFormat.format(service.price / 100), style: const TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold, fontSize: 15)),
                    if (service.isGoods) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: CupertinoColors.systemGrey5, borderRadius: BorderRadius.circular(4)), child: const Text('需绑定序列号', style: TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: CupertinoColors.activeBlue, borderRadius: BorderRadius.circular(8)),
              child: const Text('添加', style: TextStyle(color: CupertinoColors.white, fontSize: 12)),
            ),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}