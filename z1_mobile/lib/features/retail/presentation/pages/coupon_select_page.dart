import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/coupon_remote_datasource.dart';
import '../../data/models/coupon_model.dart';
import '../bloc/coupon_bloc.dart';

class CouponSelectPage extends StatelessWidget {
  const CouponSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CouponBloc(
        dataSource: CouponRemoteDataSourceImpl(
          apiClient: ctx.read<dynamic>(),
        ),
      )..add(const CouponLoadRequested()),
      child: const _CouponSelectView(),
    );
  }
}

class _CouponSelectView extends StatelessWidget {
  const _CouponSelectView();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('选择优惠券'),
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
        child: BlocBuilder<CouponBloc, CouponState>(
          builder: (context, state) {
            if (state is CouponLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (state is CouponError) {
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
                          context.read<CouponBloc>().add(const CouponLoadRequested()),
                    ),
                  ],
                ),
              );
            }
            if (state is CouponLoaded) {
              final coupons = state.availableCoupons;
              if (coupons.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.ticket,
                          size: 64, color: CupertinoColors.systemGrey),
                      const SizedBox(height: 16),
                      const Text('暂无可用优惠券'),
                      const SizedBox(height: 8),
                      CupertinoButton(
                        child: const Text('重试'),
                        onPressed: () =>
                            context.read<CouponBloc>().add(const CouponLoadRequested()),
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
                      itemCount: coupons.length,
                      itemBuilder: (ctx, index) {
                        final coupon = coupons[index];
                        final isSelected = state.selectedIds.contains(coupon.couponId);
                        return _CouponCard(
                          coupon: coupon,
                          isSelected: isSelected,
                          onTap: () {
                            context.read<CouponBloc>().add(
                                  CouponSelectionToggled(coupon),
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
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CouponLoaded state) {
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
                  selectedCount > 0 ? '已选 $selectedCount 张' : '未选择',
                  style: const TextStyle(fontSize: 13),
                ),
                if (selectedCount > 0)
                  Text(
                    '共优惠 ¥${(totalDiscount / 100).toStringAsFixed(2)}',
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
    final state = context.read<CouponBloc>().state;
    if (state is CouponLoaded) {
      final selectedCoupons = state.coupons
          .where((c) => state.selectedIds.contains(c.couponId))
          .toList();
      context.pop({
        'couponCount': selectedCoupons.length,
        'discount': state.totalDiscount,
        'coupons': selectedCoupons,
      });
    } else {
      context.pop();
    }
  }
}

class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CouponCard({
    required this.coupon,
    required this.isSelected,
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
            color: isSelected
                ? const Color(0xFFFF6B35)
                : CupertinoColors.systemGrey5,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B35).withValues(alpha: 0.1)
                    : const Color(0xFFF5F5F5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    coupon.discountDisplay,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : CupertinoColors.black,
                    ),
                  ),
                  if (coupon.type == CouponType.fixed)
                    const Text(
                      '优惠券',
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
                      coupon.couponName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.conditionDisplay,
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
                          coupon.validityDisplay,
                          style: const TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                    if (coupon.applicableProductNames != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '适用：${coupon.applicableProductNames}',
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
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                isSelected
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : CupertinoColors.systemGrey3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}