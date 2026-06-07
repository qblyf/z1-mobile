import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/models/serial_search_model.dart';
import '../bloc/serial_search_bloc.dart';

class SerialSearchPage extends StatefulWidget {
  const SerialSearchPage({super.key});

  @override
  State<SerialSearchPage> createState() => _SerialSearchPageState();
}

class _SerialSearchPageState extends State<SerialSearchPage> {
  late final SerialSearchBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<SerialSearchBloc>();
    _bloc.add(const SerialSearchWarehousesRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<SerialSearchBloc, SerialSearchState>(
        builder: (context, state) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('序列号查询'),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildSearchSection(state),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(SerialSearchState state) {
    final warehouses = state is SerialSearchInitial
        ? state.warehouses
        : state is SerialSearchLoading
            ? state.warehouses
            : state is SerialSearchLoaded
                ? state.warehouses
                : state is SerialSearchError
                    ? state.warehouses
                    : <dynamic>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _searchController,
                  placeholder: '输入序列号或条码',
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffix: _searchController.text.isNotEmpty
                      ? CupertinoButton(
                          padding: const EdgeInsets.only(right: 8),
                          onPressed: () {
                            _searchController.clear();
                            _bloc.add(const SerialSearchCleared());
                          },
                          child: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: CupertinoColors.systemGrey,
                            size: 18,
                          ),
                        )
                      : null,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _bloc.add(SerialSearchCodeSubmitted(serial: value));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(8),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _bloc.add(SerialSearchCodeSubmitted(
                        serial: _searchController.text));
                  }
                },
                child: const Text(
                  '搜索',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ],
          ),
          if (warehouses.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: warehouses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final warehouse = warehouses[index];
                  final isSelected = _isWarehouseSelected(state, warehouse.id);
                  return GestureDetector(
                    onTap: () =>
                        _bloc.add(SerialSearchWarehouseChanged(warehouse.id)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        warehouse.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoColors.label,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isWarehouseSelected(SerialSearchState state, int warehouseId) {
    if (state is SerialSearchInitial && state.selectedWarehouseId != null) {
      return state.selectedWarehouseId == warehouseId;
    } else if (state is SerialSearchLoaded &&
        state.selectedWarehouseId != null) {
      return state.selectedWarehouseId == warehouseId;
    } else if (state is SerialSearchError &&
        state.selectedWarehouseId != null) {
      return state.selectedWarehouseId == warehouseId;
    } else if (state is SerialSearchLoading &&
        state.selectedWarehouseId != null) {
      return state.selectedWarehouseId == warehouseId;
    }
    return false;
  }

  Widget _buildContent(SerialSearchState state) {
    if (state is SerialSearchInitial) {
      return _buildEmptyState();
    }

    if (state is SerialSearchLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state is SerialSearchError) {
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
            Text(
              state.message,
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('重试'),
              onPressed: () =>
                  _bloc.add(SerialSearchCodeSubmitted(serial: state.queryCode)),
            ),
          ],
        ),
      );
    }

    if (state is SerialSearchLoaded) {
      return _buildResultContent(state.result);
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.barcode_viewfinder,
            size: 64,
            color: CupertinoColors.systemGrey3,
          ),
          SizedBox(height: 16),
          Text(
            '扫码或输入序列号',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '通过扫描或输入商品序列号、条码\n查询商品信息和库存记录',
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.tertiaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(SerialSearchResultModel result) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(result),
                if (result.location != null) ...[
                  const SizedBox(height: 16),
                  _buildLocationInfo(result.location!),
                ],
              ],
            ),
          ),
        ),
        if (result.stockFlows.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '进出库历史',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final flow = result.stockFlows[index];
                  return _buildFlowItem(flow);
                },
                childCount:
                    result.stockFlows.length > 5 ? 5 : result.stockFlows.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildProductInfo(SerialSearchResultModel result) {
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
            result.productName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          if (result.spec != null) ...[
            const SizedBox(height: 4),
            Text(
              result.spec!,
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (result.barcode != null) ...[
                _InfoChip(
                  icon: CupertinoIcons.barcode,
                  label: result.barcode!,
                ),
                const SizedBox(width: 12),
              ],
              if (result.serialNumber != null)
                _InfoChip(
                  icon: CupertinoIcons.number,
                  label: result.serialNumber!,
                ),
            ],
          ),
          if (result.categoryName != null) ...[
            const SizedBox(height: 8),
            _InfoChip(
              icon: CupertinoIcons.tag,
              label: result.categoryName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo(WarehouseLocationModel location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '当前库存位置',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                CupertinoIcons.building_2_fill,
                size: 16,
                color: CupertinoColors.secondaryLabel,
              ),
              const SizedBox(width: 8),
              Text(
                location.warehouseName ?? '仓库${location.warehouseId}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (location.cabinetPosition != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.cube_box,
                  size: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
                const SizedBox(width: 8),
                Text(
                  location.cabinetPosition!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlowItem(StockFlowModel flow) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isInflow = flow.flowType == 'in';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isInflow ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isInflow
                  ? CupertinoIcons.arrow_down_circle_fill
                  : CupertinoIcons.arrow_up_circle_fill,
              color:
                  isInflow ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      flow.flowTypeLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${isInflow ? '+' : '-'}${flow.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isInflow
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(
                    DateTime.fromMillisecondsSinceEpoch(flow.flowTime * 1000),
                  ),
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
                if (flow.orderNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '单号: ${flow.orderNumber}',
                    style: const TextStyle(
                      color: CupertinoColors.tertiaryLabel,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: CupertinoColors.secondaryLabel),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
