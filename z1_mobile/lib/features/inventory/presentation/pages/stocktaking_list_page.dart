import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/datasources/stocktaking_remote_datasource.dart';
import '../../data/models/stocktaking_model.dart';
import '../bloc/stocktaking_list_bloc.dart';

class StocktakingListPage extends StatefulWidget {
  const StocktakingListPage({super.key});

  @override
  State<StocktakingListPage> createState() => _StocktakingListPageState();
}

class _StocktakingListPageState extends State<StocktakingListPage> {
  late final ScrollController _scrollController;
  late final StocktakingListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _bloc = StocktakingListBloc(
      dataSource: StocktakingRemoteDataSourceImpl(apiClient: getIt()),
    );
    _bloc.add(const StocktakingListLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _bloc.add(const StocktakingListLoadMoreRequested());
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
          middle: const Text('盘库记录'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add),
            onPressed: () => context.push('/inventory/stocktaking/add'),
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<StocktakingListBloc, StocktakingListState>(
            builder: (context, state) {
              if (state is StocktakingListLoading) {
                return const Center(child: CupertinoActivityIndicator());
              }

              if (state is StocktakingListError) {
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
                        onPressed: () => _bloc.add(const StocktakingListRefreshRequested()),
                      ),
                    ],
                  ),
                );
              }

              if (state is StocktakingListLoaded || state is StocktakingListLoadingMore) {
                final items = state is StocktakingListLoaded
                    ? state.items
                    : (state as StocktakingListLoadingMore).items;
                final isLoadingMore = state is StocktakingListLoadingMore;

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      '暂无盘库记录',
                      style: TextStyle(color: CupertinoColors.secondaryLabel),
                    ),
                  );
                }

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        _bloc.add(const StocktakingListRefreshRequested());
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
                              child: _StocktakingCard(item: items[index]),
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
      ),
    );
  }
}

class _StocktakingCard extends StatelessWidget {
  final StocktakingModel item;

  const _StocktakingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return GestureDetector(
      onTap: () => context.push('/inventory/stocktaking/${item.id}'),
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
                    item.code ?? '盘库单#${item.id}',
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
                  item.warehouseName ?? '仓库${item.warehouseID}',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final StocktakingState state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (state) {
      case StocktakingState.draft:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        break;
      case StocktakingState.inProgress:
        bgColor = const Color(0xFFE0EDFF);
        textColor = CupertinoColors.activeBlue;
        break;
      case StocktakingState.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      case StocktakingState.approved:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
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