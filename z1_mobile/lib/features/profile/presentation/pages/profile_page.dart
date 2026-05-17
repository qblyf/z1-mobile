import 'package:flutter/cupertino.dart';

/// 我的页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('👤 我的'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 用户信息卡片
            _buildUserCard(),
            const SizedBox(height: 16),

            // 本月收入构成
            _buildIncomeCard(),
            const SizedBox(height: 16),

            // 业绩排行
            _buildRankingCard(),
            const SizedBox(height: 16),

            // 审批中心入口
            _buildApprovalCard(),
            const SizedBox(height: 16),

            // 其他功能
            _buildOtherFunctions(),
            const SizedBox(height: 16),

            // 退出登录
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CupertinoColors.activeBlue, Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: const Text(
              '李',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '李明',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFE0EDFF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '收银员',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '深圳华强北旗舰店',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '入职 2 年 3 个月',
                  style: TextStyle(
                    color: CupertinoColors.tertiaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.settings,
              color: CupertinoColors.secondaryLabel,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [CupertinoColors.activeBlue, Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本月收入（5月）',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '¥12,850',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'vs 上月',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '↑ ¥1,230',
                      style: TextStyle(
                        color: Color(0xFF86EFAC),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💰 收入构成',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 12),
                _IncomeItem(
                  icon: '💵',
                  title: '基础薪资',
                  subtitle: '固定发放',
                  amount: '¥5,000',
                  color: CupertinoColors.activeBlue,
                  percent: '38.9%',
                ),
                const SizedBox(height: 8),
                _IncomeItem(
                  icon: '📈',
                  title: '销售提成',
                  subtitle: '按销售额 2%',
                  amount: '¥6,200',
                  color: const Color(0xFFFF6B35),
                  percent: '48.2%',
                ),
                const SizedBox(height: 8),
                _IncomeItem(
                  icon: '🏆',
                  title: '工分奖金',
                  subtitle: '月绩效评分 A',
                  amount: '¥1,800',
                  color: CupertinoColors.activeGreen,
                  percent: '14.0%',
                ),
                const SizedBox(height: 8),
                _IncomeItem(
                  icon: '📉',
                  title: '保险纳税',
                  subtitle: '社保+公积金+个税',
                  amount: '-¥1,150',
                  color: CupertinoColors.destructiveRed,
                  percent: '-8.9%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🏅', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '本月业绩排行',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const Text(
                  '门店 12 人',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // 我的排名
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9E6),
              border: Border(
                bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB020),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '我的排名',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      Text(
                        '销售额 ¥285,600',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '↑ 2 名',
                      style: TextStyle(
                        color: CupertinoColors.activeGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '较上月提升',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _RankingItem(rank: '1', name: '王小红', amount: '¥352,800', tag: '本月销冠', tagColor: const Color(0xFFFFB020)),
          _RankingItem(rank: '2', name: '张伟', amount: '¥318,500', subtitle: '差距 ¥33,000'),
          _RankingItem(
            rank: '3',
            name: '李明',
            amount: '¥285,600',
            subtitle: '还需 ¥67,200',
            highlight: true,
            showBorder: false,
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text(
                '查看完整排行 >',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text('✅', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '审批中心',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _MenuItem(
            icon: '📋',
            title: '待我审批',
            subtitle: '退换货、调拨、积分调整',
            tag: '2 项',
            tagColor: CupertinoColors.destructiveRed,
          ),
          _MenuItem(
            icon: '📤',
            title: '我发起的',
            subtitle: '查看我提交的审批',
            trailing: '3 项进行中',
          ),
          _MenuItem(
            icon: '📜',
            title: '审批历史',
            subtitle: '已处理的审批记录',
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOtherFunctions() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _MenuItem(icon: '🏪', title: '门店切换', subtitle: '深圳华强北旗舰店'),
          _MenuItem(icon: '📊', title: '收入明细'),
          _MenuItem(icon: '⚙️', title: '设置', showBorder: false),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: CupertinoColors.white,
      borderRadius: BorderRadius.circular(12),
      onPressed: () {},
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.square_arrow_right,
            color: CupertinoColors.destructiveRed,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            '退出登录',
            style: TextStyle(
              color: CupertinoColors.destructiveRed,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String amount;
  final Color color;
  final String percent;

  const _IncomeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(
                  subtitle,
                  style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '占比 $percent',
                style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final String rank;
  final String name;
  final String amount;
  final String? tag;
  final Color? tagColor;
  final String? subtitle;
  final bool highlight;
  final bool showBorder;

  const _RankingItem({
    required this.rank,
    required this.name,
    required this.amount,
    this.tag,
    this.tagColor,
    this.subtitle,
    this.highlight = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF9E6) : null,
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == '1'
                  ? const Color(0xFFFFB020)
                  : rank == '2'
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFFFFB020),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              rank,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    if (highlight)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '我',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 10),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: highlight ? const Color(0xFF86EFAC) : CupertinoColors.label,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (tag != null)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: tagColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag!,
                    style: TextStyle(color: tagColor, fontSize: 9, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final String? tag;
  final Color? tagColor;
  final String? trailing;
  final bool showBorder;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.tag,
    this.tagColor,
    this.trailing,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag!,
                style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11),
            ),
          const SizedBox(width: 8),
          const Icon(
            CupertinoIcons.chevron_forward,
            color: CupertinoColors.tertiaryLabel,
            size: 16,
          ),
        ],
      ),
    );
  }
}