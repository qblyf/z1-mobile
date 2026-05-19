import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/models/order_model.dart';
import '../bloc/home_bloc.dart';

/// 首页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = HomeBloc(dataSource: HomeRemoteDataSourceImpl(apiClient: getIt()));
        bloc.add(const HomeLoadRequested());
        return bloc;
      },
      child: _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('掌上高远'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.bell),
              onPressed: () {},
            ),
          ),
          child: SafeArea(
            child: _buildContent(context, state),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state is HomeError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle, size: 48, color: CupertinoColors.systemGrey),
              const SizedBox(height: 16),
              Text(
                '加载失败: ${state.message}',
                style: const TextStyle(color: CupertinoColors.secondaryLabel),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                child: const Text('重试'),
                onPressed: () => context.read<HomeBloc>().add(const HomeLoadRequested()),
              ),
            ],
          ),
        ),
      );
    }

    if (state is HomeLoaded) {
      return _buildLoadedContent(context, state);
    }

    // Initial or other states - show loading
    return const Center(child: CupertinoActivityIndicator());
  }

  Widget _buildLoadedContent(BuildContext context, HomeLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return CupertinoScrollbar(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 欢迎语
          _buildWelcomeCard(state.user.realName),
          const SizedBox(height: 16),

          // 门店信息卡片
          _buildStoreCard(),
          const SizedBox(height: 16),

          // 快捷操作
          _buildQuickActions(context),
          const SizedBox(height: 16),

          // 今日数据
          _buildTodayStats(state.stats, currencyFormat),
          const SizedBox(height: 16),

          // 功能菜单
          _buildFunctionMenu(context),
          const SizedBox(height: 16),

          // 最近订单
          _buildRecentOrders(context, state.recentOrders, currencyFormat),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.hand_raised_fill, color: CupertinoColors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            '欢迎回来，$userName',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            CupertinoIcons.building_2_fill,
            color: CupertinoColors.activeBlue,
            size: 32,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '深圳华强北旗舰店',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '当前门店',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickActionButton(
          icon: CupertinoIcons.barcode_viewfinder,
          label: '快速扫码',
          color: CupertinoColors.activeOrange,
          onTap: () {},
        ),
        _QuickActionButton(
          icon: CupertinoIcons.search,
          label: '查序列号',
          color: CupertinoColors.activeGreen,
          onTap: () {},
        ),
        _QuickActionButton(
          icon: CupertinoIcons.person_2,
          label: '查会员',
          color: const Color(0xFFAF52DE),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildTodayStats(HomeStats stats, NumberFormat formatter) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: '今日销售额',
            value: formatter.format(stats.todaySales),
            subtitle: stats.salesGrowth > 0 ? '↑ ${stats.salesGrowth.toStringAsFixed(0)}%' : '',
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: '今日订单数',
            value: stats.todayOrderCount.toString(),
            subtitle: '已完成 ${stats.todayOrderCount}',
            color: CupertinoColors.activeGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '📌 常用功能',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _MenuCard(
              icon: CupertinoIcons.cart,
              label: '零售开单',
              color: const Color(0xFFFF6B35),
              onTap: () => context.go('/home/retail/entry'),
            ),
            _MenuCard(
              icon: CupertinoIcons.doc_text,
              label: '订单列表',
              color: CupertinoColors.activeBlue,
              onTap: () => context.go('/home/order/list'),
            ),
            _MenuCard(
              icon: CupertinoIcons.archivebox,
              label: '库存管理',
              color: CupertinoColors.activeGreen,
              onTap: () {},
            ),
            _MenuCard(
              icon: CupertinoIcons.person_2,
              label: '会员中心',
              color: const Color(0xFFAF52DE),
              onTap: () => context.go('/member'),
            ),
            _MenuCard(
              icon: CupertinoIcons.calendar,
              label: '行事历',
              color: CupertinoColors.activeOrange,
              onTap: () => context.go('/task'),
            ),
            _MenuCard(
              icon: CupertinoIcons.checkmark_seal,
              label: '审批中心',
              color: CupertinoColors.systemGrey,
              badge: '2',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrders(BuildContext context, List orders, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📌 最近订单',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text(
                  '查看全部 >',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () => context.go('/home/order/list'),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: orders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      '暂无订单',
                      style: TextStyle(color: CupertinoColors.secondaryLabel),
                    ),
                  ),
                )
              : Column(
                  children: orders.asMap().entries.map((entry) {
                    final index = entry.key;
                    final order = entry.value;
                    return _OrderListTile(
                      orderNumber: order.orderNumber,
                      time: order.timeAgo,
                      amount: formatter.format(order.orderAmountYuan),
                      status: order.statusText,
                      showBorder: index < orders.length - 1,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: CupertinoColors.destructiveRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final String orderNumber;
  final String time;
  final String amount;
  final String status;
  final bool showBorder;

  const _OrderListTile({
    required this.orderNumber,
    required this.time,
    required this.amount,
    required this.status,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('📦', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time · $status',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: CupertinoColors.destructiveRed,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}