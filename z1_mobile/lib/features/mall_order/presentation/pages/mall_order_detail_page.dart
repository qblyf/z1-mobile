import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection.dart';
import '../../../../types/api/mall-order-types.dart';
import '../../data/datasources/mall_order_remote_datasource.dart';
import '../../data/models/mall_order_detail_model.dart';
import '../../data/models/mall_order_model.dart';
import '../bloc/mall_order_detail_bloc.dart';
import '../utils.dart';

/// 商城订单详情页（PRD 3.2 布局）
///
/// MVP：状态徽章 + 单号/时间 + 收货人（自提订单跳过）+ 行项明细 +
/// 金额合计 + 物流信息（暂仅占位）。退款/取消/查看物流入口预留按钮位但
/// 跳转路由待对应模块就绪。
class MallOrderDetailPage extends StatefulWidget {
  final String number;

  const MallOrderDetailPage({super.key, required this.number});

  @override
  State<MallOrderDetailPage> createState() => _MallOrderDetailPageState();
}

class _MallOrderDetailPageState extends State<MallOrderDetailPage> {
  late final MallOrderDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MallOrderDetailBloc(
      dataSource: MallOrderRemoteDataSourceImpl(apiClient: getIt()),
    )..add(MallOrderDetailLoadRequested(widget.number));
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
        navigationBar: const CupertinoNavigationBar(middle: Text('商城订单详情')),
        child: SafeArea(
          child: BlocBuilder<MallOrderDetailBloc, MallOrderDetailState>(
            builder: (context, state) {
              if (state is MallOrderDetailLoading ||
                  state is MallOrderDetailInitial) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (state is MallOrderDetailError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () =>
                      _bloc.add(const MallOrderDetailRefreshRequested()),
                );
              }
              if (state is MallOrderDetailLoaded) {
                return _DetailBody(detail: state.detail);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Body
// ============================================================================

class _DetailBody extends StatelessWidget {
  final MallOrderDetailModel detail;

  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final summary = detail.summary;
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            final bloc = context.read<MallOrderDetailBloc>();
            bloc.add(const MallOrderDetailRefreshRequested());
            // 等待终态（Loaded/Error）；超时或 BLoC 已关闭则直接放手势。
            try {
              await bloc.stream
                  .firstWhere(
                    (s) =>
                        s is MallOrderDetailLoaded || s is MallOrderDetailError,
                  )
                  .timeout(const Duration(seconds: 15));
            } catch (_) {
              // ignore: refresh 手势复位即可，错误已落到 state
            }
          },
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            _StatusHeader(summary: summary),
            _Section(
              title: '订单信息',
              children: [
                _kv('单号', summary.number),
                _kv('创建时间', _formatTime(summary.createdAt)),
                if (detail.paymentAt != null && detail.paymentAt! > 0)
                  _kv('支付时间', _formatTime(detail.paymentAt!)),
                _kv(
                  '配送方式',
                  detail.isSelfPickup ? '到店自提' : '快递邮寄',
                ),
              ],
            ),
            if (!detail.isSelfPickup && detail.shippingInfo != null)
              _Section(
                title: '收货人信息',
                children: [
                  _kv('姓名', detail.shippingInfo!.name),
                  _kv('手机', detail.shippingInfo!.maskedMobilePhone),
                  _kv('地址', detail.shippingInfo!.address),
                ],
              ),
            _LineItemsSection(items: detail.lineItems),
            _AmountSummary(detail: detail),
            if ((detail.remarks ?? '').isNotEmpty)
              _Section(
                title: '备注',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(detail.remarks!),
                  ),
                ],
              ),
            _ActionBar(detail: detail),
            const SizedBox(height: 24),
          ]),
        ),
      ],
    );
  }

  static Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Sections
// ============================================================================

class _StatusHeader extends StatelessWidget {
  final MallOrderModel summary;
  const _StatusHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _statusColors(summary.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.status.label,
            style: TextStyle(
              color: fg,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '订单号 ${summary.number}',
            style: TextStyle(color: fg.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: CupertinoColors.systemBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LineItemsSection extends StatelessWidget {
  final List<MallOrderLineItem> items;
  const _LineItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '商品明细',
      children: [
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '暂无明细',
              style: TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          )
        else
          for (final item in items) _LineItemRow(item: item),
      ],
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final MallOrderLineItem item;
  const _LineItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    final hasDiscount = item.discountPrice != item.unitPrice;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.kind.label} · 数量 x${item.qty}',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(item.discountPriceYuan),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(height: 2),
                Text(
                  currency.format(item.unitPriceYuan),
                  style: const TextStyle(
                    color: CupertinoColors.tertiaryLabel,
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountSummary extends StatelessWidget {
  final MallOrderDetailModel detail;
  const _AmountSummary({required this.detail});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    final s = detail.summary;
    final coinsAmt = detail.coinsUsedAmountYuan;
    final postAmt = detail.postAmountYuan;
    return _Section(
      title: '金额信息',
      children: [
        _row('商品总价', currency.format(s.orderAmountYuan)),
        if (detail.discountAmount > 0)
          _row(
            '优惠',
            '-${currency.format(detail.discountAmountYuan)}',
            valueColor: CupertinoColors.destructiveRed,
          ),
        if (coinsAmt != null && coinsAmt > 0)
          _row(
            '积分抵扣',
            '-${currency.format(coinsAmt)}',
            valueColor: CupertinoColors.destructiveRed,
          ),
        if (postAmt != null && postAmt > 0)
          _row('邮费', currency.format(postAmt)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: CupertinoColors.separator),
          ),
        ),
        _row(
          '实付',
          currency.format(s.payAmountYuan),
          emphasize: true,
        ),
      ],
    );
  }

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
    bool emphasize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: emphasize ? 14 : 13,
                color: emphasize
                    ? CupertinoColors.label
                    : CupertinoColors.secondaryLabel,
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 16 : 13,
              color: valueColor ??
                  (emphasize
                      ? CupertinoColors.destructiveRed
                      : CupertinoColors.label),
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          CupertinoButton.filled(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

String _formatTime(int unixSeconds) => formatMallOrderTime(unixSeconds);

(Color bg, Color fg) _statusColors(MallOrderStatus status) =>
    mallOrderStatusColors(status);

// ============================================================================
// 操作按钮区（MVP：完成订单 + 取消待支付订单）
// ============================================================================

/// 按订单状态显示对应可用操作；其它操作（已支付取消 / 退款 / 物流）暂未做。
///
/// ⚠️ 调用的 POST 接口（`/mall-order/finish` / `/mall-order/unpaid-cancel`）
/// 是破坏性接口，本期没有空跑过参数名，需要业务方提供可作废的测试订单时验证。
class _ActionBar extends StatefulWidget {
  final MallOrderDetailModel detail;
  const _ActionBar({required this.detail});

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.detail.summary.status;
    final actions = <Widget>[];

    // 待支付：可取消
    if (status == MallOrderStatus.pendingPayment) {
      actions.add(
        _ActionButton(
          label: '取消订单',
          destructive: true,
          onPressed: _busy ? null : _confirmCancel,
        ),
      );
    }

    // 已支付/部分支付/已出库：可标记完成（核心：自提送出后店员标记）
    if (status == MallOrderStatus.paid ||
        status == MallOrderStatus.partiallyPaid ||
        status == MallOrderStatus.shipped ||
        status == MallOrderStatus.delivered) {
      actions.add(
        _ActionButton(
          label: '完成订单',
          onPressed: _busy ? null : _confirmFinish,
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CupertinoColors.systemBackground,
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmFinish() async {
    final confirmed = await _showConfirm(
      title: '确认完成订单',
      content: '订单号 ${widget.detail.summary.number}\n标记为已完成后状态不可逆。',
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    final ds = MallOrderRemoteDataSourceImpl(apiClient: getIt());
    final result = await ds.finishMallOrder(widget.detail.summary.number);
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isFailure) {
      await _showAlert('完成失败', result.failure!.message);
      return;
    }
    await _showAlert('已完成', '订单已标记为完成');
    if (!mounted) return;
    context.read<MallOrderDetailBloc>().add(
      const MallOrderDetailRefreshRequested(),
    );
  }

  Future<void> _confirmCancel() async {
    final confirmed = await _showConfirm(
      title: '确认取消订单',
      content: '订单号 ${widget.detail.summary.number}\n取消后不可恢复。',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    final ds = MallOrderRemoteDataSourceImpl(apiClient: getIt());
    final result = await ds.cancelUnpaidOrder(widget.detail.summary.number);
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isFailure) {
      await _showAlert('取消失败', result.failure!.message);
      return;
    }
    await _showAlert('已取消', '订单已取消');
    if (!mounted) return;
    context.read<MallOrderDetailBloc>().add(
      const MallOrderDetailRefreshRequested(),
    );
  }

  Future<bool> _showConfirm({
    required String title,
    required String content,
    required bool destructive,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('再想想'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: destructive,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showAlert(String title, String content) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('好'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool destructive;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    this.destructive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (destructive) {
      return CupertinoButton(
        color: CupertinoColors.destructiveRed,
        disabledColor: CupertinoColors.systemGrey3,
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: CupertinoColors.white),
        ),
      );
    }
    return CupertinoButton.filled(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
