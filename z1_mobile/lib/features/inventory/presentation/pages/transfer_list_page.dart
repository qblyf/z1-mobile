import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/datasources/transfer_remote_datasource.dart';
import '../../data/models/transfer_model.dart';
import '../bloc/transfer_list_bloc.dart';

class TransferListPage extends StatefulWidget {
  const TransferListPage({super.key});

  @override
  State<TransferListPage> createState() => _TransferListPageState();
}

class _TransferListPageState extends State<TransferListPage> {
  late final ScrollController _scrollController;
  late final TransferListBloc _bloc;
  int _selectedFilterIndex = 0;

  static const _filters = ['全部', '待发货', '待入库', '已完成'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _bloc = TransferListBloc(
      dataSource: TransferRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(const TransferListLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _bloc.add(const TransferListLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('调拨'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add),
            onPressed: () => context.push('/inventory/transfer/add'),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _selectedFilterIndex,
                    children: {
                      for (int i = 0; i < _filters.length; i++)
                        i: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(_filters[i], style: const TextStyle(fontSize: 13)),
                        ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        _selectedFilterIndex = value ?? 0;
                      });
                      _bloc.add(TransferListFilterChanged(value == 0 ? null : value! - 1));
                    },
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<TransferListBloc, TransferListState>(
                  builder: (context, state) {
                    if (state is TransferListLoading) {
                      return const Center(child: CupertinoActivityIndicator());
                    }

                    if (state is TransferListError) {
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
                              onPressed: () => _bloc.add(const TransferListRefreshRequested()),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is TransferListLoaded || state is TransferListLoadingMore) {
                      final items = state is TransferListLoaded
                          ? state.items
                          : (state as TransferListLoadingMore).items;
                      final isLoadingMore = state is TransferListLoadingMore;

                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            '暂无调拨记录',
                            style: TextStyle(color: CupertinoColors.secondaryLabel),
                          ),
                        );
                      }

                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () async {
                              _bloc.add(const TransferListRefreshRequested());
                              await Future.delayed(const Duration(milliseconds: 500));
                            },
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                    child: _TransferCard(item: items[index]),
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

class _TransferCard extends StatelessWidget {
  final TransferModel item;

  const _TransferCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return GestureDetector(
      onTap: () => context.push('/inventory/transfer/${item.id}'),
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
                    item.code ?? '调拨单#${item.id}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                _StateBadge(state: item.state),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(CupertinoIcons.arrow_right, size: 14, color: CupertinoColors.secondaryLabel),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${item.fromWarehouseName ?? '源仓库${item.fromWarehouseID}'} → ${item.toWarehouseName ?? '目标仓库${item.toWarehouseID}'}',
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                const Icon(CupertinoIcons.cube_box, size: 14, color: CupertinoColors.secondaryLabel),
                const SizedBox(width: 4),
                Text(
                  '${item.productCount} 品项',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final TransferState state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (state) {
      case TransferState.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        break;
      case TransferState.shipping:
        bgColor = const Color(0xFFE0EDFF);
        textColor = CupertinoColors.activeBlue;
        break;
      case TransferState.completed:
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