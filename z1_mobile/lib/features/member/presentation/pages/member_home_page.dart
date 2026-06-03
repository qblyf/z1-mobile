import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection.dart';
import '../../data/models/member_model.dart';
import '../bloc/member_home_bloc.dart';

class MemberHomePage extends StatelessWidget {
  const MemberHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MemberHomeBloc>()..add(const MemberHomeLoadRequested()),
      child: const _MemberHomePageContent(),
    );
  }
}

class _MemberHomePageContent extends StatefulWidget {
  const _MemberHomePageContent();

  @override
  State<_MemberHomePageContent> createState() => _MemberHomePageContentState();
}

class _MemberHomePageContentState extends State<_MemberHomePageContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('会员中心'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<MemberHomeBloc, MemberHomeState>(
                builder: (context, state) {
                  if (state is MemberHomeLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (state is MemberHomeError) {
                    return _buildErrorView(context, state.message);
                  }

                  if (state is MemberHomeEmpty) {
                    return _buildEmptyView(context, state.searchKeyword);
                  }

                  if (state is MemberHomeLoaded) {
                    return _buildMemberList(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CupertinoTextField(
        controller: _searchController,
        placeholder: '搜索手机号/姓名',
        prefix: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(CupertinoIcons.search, color: CupertinoColors.systemGrey),
        ),
        suffix: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {});
                  context.read<MemberHomeBloc>().add(const MemberHomeClearSearch());
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(CupertinoIcons.clear_circled_solid, color: CupertinoColors.systemGrey, size: 18),
                ),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        onChanged: (value) {
          setState(() {});
          context.read<MemberHomeBloc>().add(MemberHomeSearchRequested(value));
        },
      ),
    );
  }

  Widget _buildMemberList(BuildContext context, MemberHomeLoaded state) {
    return CustomScrollView(
      slivers: [
        if (!state.isSearchResult && state.recentMembers.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('最近服务'),
                _buildRecentMembers(context, state.recentMembers),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: _buildSectionTitle(state.isSearchResult ? '搜索结果' : '全部会员'),
        ),
        if (state.members.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('暂无会员数据', style: TextStyle(color: CupertinoColors.systemGrey)),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMemberCard(context, state.members[index]),
              childCount: state.members.length,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 16, right: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecentMembers(BuildContext context, List<MemberModel> recentMembers) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recentMembers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = recentMembers[index];
          return GestureDetector(
            onTap: () => context.push('/member/${member.id}'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : '?',
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(member.name, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MemberModel member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              member.name.isNotEmpty ? member.name[0] : '?',
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        member.levelName,
                        style: const TextStyle(color: Color(0xFF2196F3), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.maskedPhone,
                  style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member.availableExperience}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text('积分', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, String? searchKeyword) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.person_crop_circle_badge_xmark, size: 64, color: CupertinoColors.systemGrey),
          const SizedBox(height: 16),
          Text(
            searchKeyword != null && searchKeyword.isNotEmpty ? '未找到该会员' : '暂无会员数据',
            style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle, size: 64, color: CupertinoColors.systemGrey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: CupertinoColors.systemGrey)),
          const SizedBox(height: 16),
          CupertinoButton(
            child: const Text('重试'),
            onPressed: () => context.read<MemberHomeBloc>().add(const MemberHomeLoadRequested()),
          ),
        ],
      ),
    );
  }
}