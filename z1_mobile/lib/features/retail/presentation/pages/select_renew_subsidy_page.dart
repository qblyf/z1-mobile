import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/renew_subsidy_remote_datasource.dart';
import '../../data/models/renew_subsidy_model.dart';
import '../bloc/renew_subsidy_bloc.dart';

/// 换新补贴选择页面
/// 用于零售开单中选择可用的换新补贴券
class SelectRenewSubsidyPage extends StatelessWidget {
  const SelectRenewSubsidyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RenewSubsidyBloc(
        dataSource: RenewSubsidyRemoteDataSourceImpl(
          apiClient: ctx.read<dynamic>(),
        ),
      )..add(const RenewSubsidyLoadClassRequested()),
      child: const _SelectRenewSubsidyView(),
    );
  }
}

class _SelectRenewSubsidyView extends StatefulWidget {
  const _SelectRenewSubsidyView();

  @override
  State<_SelectRenewSubsidyView> createState() => _SelectRenewSubsidyViewState();
}

class _SelectRenewSubsidyViewState extends State<_SelectRenewSubsidyView> {
  int _selectedClassIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('选择换新补贴'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('取消'),
          onPressed: () => context.pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('确定'),
          onPressed: () => _onConfirm(context),
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<RenewSubsidyBloc, RenewSubsidyState>(
          builder: (context, state) {
            if (state is RenewSubsidyClassLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (state is RenewSubsidyError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_circle,
                        size: 48, color: CupertinoColors.destructiveRed),
                    const SizedBox(height: 16),
                    Text(state.message,
                        style: const TextStyle(color: CupertinoColors.secondaryLabel)),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      child: const Text('重试'),
                      onPressed: () =>
                          context.read<RenewSubsidyBloc>().add(const RenewSubsidyLoadClassRequested()),
                    ),
                  ],
                ),
              );
            }
            if (state is RenewSubsidyClassLoaded) {
              final classes = state.classes;
              final subsidies = state.subsidies;

              if (classes.isEmpty && subsidies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.gift,
                          size: 64, color: CupertinoColors.systemGrey),
                      const SizedBox(height: 16),
                      const Text('暂无可用换新补贴'),
                      const SizedBox(height: 8),
                      CupertinoButton(
                        child: const Text('重试'),
                        onPressed: () =>
                            context.read<RenewSubsidyBloc>().add(const RenewSubsidyLoadClassRequested()),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // 分类 Tab
                  if (classes.isNotEmpty)
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: classes.length,
                        itemBuilder: (ctx, index) {
                          final classModel = classes[index];
                          final isSelected = _selectedClassIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedClassIndex = index;
                                });
                                context.read<RenewSubsidyBloc>().add(
                                      RenewSubsidyLoadRequested(
                                        classId: classModel.classId.toString(),
                                      ),
                                    );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFF6B35)
                                      : CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  classModel.className,
                                  style: TextStyle(
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: subsidies.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.gift,
                                    size: 48, color: CupertinoColors.systemGrey),
                                SizedBox(height: 12),
                                Text(
                                  '该分类暂无可用补贴',
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: subsidies.length,
                            itemBuilder: (ctx, index) {
                              final subsidy = subsidies[index];
                              return _RenewSubsidyCard(
                                subsidy: subsidy,
                                onTap: () {
                                  context.read<RenewSubsidyBloc>().add(
                                        RenewSubsidySelectionToggled(subsidy),
                                      );
                                },
                              );
                            },
                          ),
                  ),
                  _buildBottomBar(context, state),
                ],
              );
            }
            if (state is RenewSubsidyLoaded) {
              final subsidies = state.availableSubsidies;
              if (subsidies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.gift,
                          size: 64, color: CupertinoColors.systemGrey),
                      const SizedBox(height: 16),
                      const Text('暂无可用换新补贴'),
                      const SizedBox(height: 8),
                      CupertinoButton(
                        child: const Text('重试'),
                        onPressed: () =>
                            context.read<RenewSubsidyBloc>().add(const RenewSubsidyLoadRequested()),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: subsidies.length,
                      itemBuilder: (ctx, index) {
                        final subsidy = subsidies[index];
                        return _RenewSubsidyCard(
                          subsidy: subsidy,
                          onTap: () {
                            context.read<RenewSubsidyBloc>().add(
                                  RenewSubsidySelectionToggled(subsidy),
                                );
                          },
                        );
                      },
                    ),
                  ),
                  _buildBottomBarForLoaded(context, state),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, RenewSubsidyClassLoaded state) {
    final subsidies = state.subsidies;
    // 简化版，暂不支持多选 —— 选数 / 优惠合计计算在接入多选后再补

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subsidies.isEmpty ? '暂无可用' : '共 ${subsidies.length} 个可用',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              borderRadius: BorderRadius.circular(20),
              onPressed: subsidies.isEmpty
                  ? null
                  : () {
                      // 默认选择第一个可用的补贴
                      if (subsidies.isNotEmpty) {
                        context.pop({
                          'subsidyCount': 1,
                          'discount': subsidies.first.discountValue,
                          'subsidy': subsidies.first,
                        });
                      } else {
                        context.pop();
                      }
                    },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarForLoaded(BuildContext context, RenewSubsidyLoaded state) {
    final selectedCount = state.selectedCount;
    final totalDiscount = state.totalDiscount;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCount > 0 ? '已选 $selectedCount 个' : '未选择',
                  style: const TextStyle(fontSize: 13),
                ),
                if (selectedCount > 0)
                  Text(
                    '共补贴 ¥${(totalDiscount / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.activeGreen,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              borderRadius: BorderRadius.circular(20),
              onPressed: () => _onConfirm(context),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirm(BuildContext context) {
    final state = context.read<RenewSubsidyBloc>().state;
    if (state is RenewSubsidyLoaded) {
      final selectedSubsidies = state.subsidies
          .where((s) => state.selectedIds.contains(s.subsidyId))
          .toList();
      context.pop({
        'subsidyCount': selectedSubsidies.length,
        'discount': state.totalDiscount,
        'subsidies': selectedSubsidies,
      });
    } else {
      context.pop();
    }
  }
}

class _RenewSubsidyCard extends StatelessWidget {
  final RenewSubsidyModel subsidy;
  final VoidCallback onTap;

  const _RenewSubsidyCard({
    required this.subsidy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subsidy.discountDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const Text(
                    '换新补贴',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subsidy.subsidyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subsidy.conditionDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          size: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subsidy.validityDisplay,
                          style: const TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                    if (subsidy.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subsidy.description!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF6B35),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}