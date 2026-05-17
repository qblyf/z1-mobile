import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/models/purchase_model.dart';
import '../bloc/purchase_list_bloc.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  late final ScrollController _scrollController;
  late final PurchaseListBloc _bloc;
  PurchaseState? _selectedState;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _bloc = PurchaseListBloc(
      dataSource: PurchaseRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(const PurchaseListLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _bloc.add(const PurchaseListLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onFilterChanged(PurchaseState? state) {
    setState(() {
      _selectedState = state;
    });
    _bloc.add(PurchaseListFilterChanged(state));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('采购'),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _FilterTabs(
                selectedState: _selectedState,
                onFilterChanged: _onFilterChanged,
              ),
              Expanded(
                child: BlocBuilder<PurchaseListBloc, PurchaseListState>(
                  builder: (context, state) {
                    if (state is PurchaseListLoading) {
                      return const Center(child: CupertinoActivityIndicator());
                    }

                    if (state is PurchaseListError) {
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
                              style: const TextStyle(
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              child: const Text('重试'),
                              onPressed: () => _bloc.add(const PurchaseListRefreshRequested()),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is PurchaseListLoaded || state is PurchaseListLoadingMore) {
                      final items = state is PurchaseListLoaded
                          ? state.items
                          : (state as PurchaseListLoadingMore).items;
                      final isLoadingMore = state is PurchaseListLoadingMore;

                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            '暂无采购记录',
                            style: TextStyle(color: CupertinoColors.secondaryLabel),
                          ),
                        );
                      }

                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () async {
                              _bloc.add(const PurchaseListRefreshRequested());
                              await Future.delayed(const Duration(milliseconds: 500));
                            },
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index >= items.length) {
                                    return isLoadingMore
                                        ? const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Center(
                                              child: CupertinoActivityIndicator(),
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _PurchaseCard(item: items[index]),
                                  );
                                },
                                childCount: items.length + (isLoadingMore ? 1 : 0),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final PurchaseState? selectedState;
  final ValueChanged<PurchaseState?> onFilterChanged;

  const _FilterTabs({
    required this.selectedState,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: '全部',
            isSelected: selectedState == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '待入库',
            isSelected: selectedState == PurchaseState.pending,
            onTap: () => onFilterChanged(PurchaseState.pending),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '部分入库',
            isSelected: selectedState == PurchaseState.partial,
            onTap: () => onFilterChanged(PurchaseState.partial),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '已完成',
            isSelected: selectedState == PurchaseState.completed,
            onTap: () => onFilterChanged(PurchaseState.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.activeBlue : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? CupertinoColors.white : const Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final PurchaseModel item;

  const _PurchaseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return GestureDetector(
      onTap: () => _showActionSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.code ?? '采购单#${item.id}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                _StateBadge(state: item.state),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(CupertinoIcons.building_2_fill, size: 14, color: CupertinoColors.secondaryLabel),
                const SizedBox(width: 4),
                Text(
                  item.supplierName ?? '供应商',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(CupertinoIcons.clock, size: 14, color: CupertinoColors.secondaryLabel),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.createdAt * 1000)),
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${item.productCount}品项',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  item.formattedAmount,
                  style: const TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/inventory/purchase-list/${item.id}');
            },
            child: const Text('查看详情'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/inventory/purchase-inbound/${item.id}');
            },
            child: const Text('采购入库'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('取消'),
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final PurchaseState state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (state) {
      case PurchaseState.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case PurchaseState.partial:
        bgColor = const Color(0xFFE0EDFF);
        textColor = CupertinoColors.activeBlue;
        break;
      case PurchaseState.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        state.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}