import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/retail_order_model.dart';
import '../bloc/member_bloc.dart';

class RetailEntryPage extends StatefulWidget {
  const RetailEntryPage({super.key});

  @override
  State<RetailEntryPage> createState() => _RetailEntryPageState();
}

class _RetailEntryPageState extends State<RetailEntryPage> {
  SalesType _selectedType = SalesType.retail;
  final TextEditingController _phoneController = TextEditingController();
  MemberInfo? _boundMember;
  bool _isWalkIn = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<MemberBloc>().add(const MemberLoadRecentRequested());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<MemberBloc>().add(MemberSearchByPhoneRequested(value));
    });
  }

  void _selectSalesType(SalesType type) {
    setState(() => _selectedType = type);
  }

  void _bindMember(MemberInfo member) {
    setState(() {
      _boundMember = member;
      _isWalkIn = false;
      _phoneController.text = member.mobilePhone;
    });
  }

  void _selectWalkIn() {
    setState(() {
      _boundMember = null;
      _isWalkIn = true;
      _phoneController.clear();
    });
  }

  void _startOrder() {
    final order = RetailOrder(
      salesType: _selectedType,
      customerIdent: _boundMember?.ident,
      customerName: _boundMember?.realName,
    );

    context.push('/order/retail/product', extra: order);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('零售开单'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSalesTypeSection(),
            const SizedBox(height: 16),
            _buildMemberBindSection(),
            const SizedBox(height: 16),
            _buildWalkInSection(),
            const SizedBox(height: 24),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTypeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择销售类型',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SalesTypeCard(
                  icon: '🛍️',
                  label: '零售',
                  subtitle: '标准价格',
                  isSelected: _selectedType == SalesType.retail,
                  onTap: () => _selectSalesType(SalesType.retail),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SalesTypeCard(
                  icon: '📦',
                  label: '批发',
                  subtitle: '批量价格',
                  isSelected: _selectedType == SalesType.wholesale,
                  onTap: () => _selectSalesType(SalesType.wholesale),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SalesTypeCard(
                  icon: '🏗️',
                  label: '工程',
                  subtitle: '项目价格',
                  isSelected: _selectedType == SalesType.project,
                  onTap: () => _selectSalesType(SalesType.project),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberBindSection() {
    return Container(
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
              const Text(
                '绑定会员（可选）',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              if (_boundMember != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _boundMember = null), minimumSize: const Size(0, 0),
                  child: const Text(
                    '解除',
                    style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_boundMember != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      color: CupertinoColors.activeGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _boundMember!.realName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _boundMember!.mobilePhone,
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: CupertinoColors.activeGreen,
                  ),
                ],
              ),
            ),
          ] else ...[
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        CupertinoIcons.qrcode_viewfinder,
                        color: CupertinoColors.activeGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '企业微信扫码绑定',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '扫描客户二维码自动识别会员',
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_forward,
                      color: CupertinoColors.tertiaryLabel,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Container(height: 1, color: CupertinoColors.separator)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '或',
                    style: TextStyle(
                      color: CupertinoColors.tertiaryLabel,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: CupertinoColors.separator)),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _phoneController,
                    placeholder: '输入手机号查找会员',
                    keyboardType: TextInputType.phone,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onChanged: _onPhoneChanged,
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    context.read<MemberBloc>().add(
                      MemberSearchByPhoneRequested(_phoneController.text),
                    );
                  },
                  child: const Text('查找'),
                ),
              ],
            ),

            const SizedBox(height: 12),
            BlocBuilder<MemberBloc, MemberState>(
              builder: (context, state) {
                if (state is MemberLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (state is MemberLoaded && state.searchResults.isNotEmpty) {
                  return Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.separator),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.searchResults.length,
                      itemBuilder: (context, index) {
                        final member = state.searchResults[index];
                        return CupertinoButton(
                          padding: const EdgeInsets.all(12),
                          onPressed: () {
                            _bindMember(MemberInfo(
                              ident: member.ident,
                              realName: member.realName,
                              mobilePhone: member.mobilePhone,
                              experience: member.experience,
                            ));
                            context.read<MemberBloc>().add(const MemberSearchCleared());
                          },
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.person, size: 18),
                              const SizedBox(width: 8),
                              Text(member.realName),
                              const SizedBox(width: 8),
                              Text(
                                member.mobilePhone,
                                style: const TextStyle(color: CupertinoColors.secondaryLabel),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                if (state is MemberLoaded && state.recentMembers.isNotEmpty && _phoneController.text.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '最近会员',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.recentMembers.take(5).map((member) {
                          return GestureDetector(
                            onTap: () {
                              _bindMember(MemberInfo(
                                ident: member.ident,
                                realName: member.realName,
                                mobilePhone: member.mobilePhone,
                                experience: member.experience,
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                member.mobilePhone,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWalkInSection() {
    return GestureDetector(
      onTap: _selectWalkIn,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isWalkIn ? const Color(0xFFFFF3E0) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isWalkIn ? CupertinoColors.activeOrange : CupertinoColors.separator,
            width: _isWalkIn ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isWalkIn ? CupertinoColors.activeOrange.withValues(alpha: 0.2) : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.person,
                color: _isWalkIn ? CupertinoColors.activeOrange : CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '散客直接开单',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: _isWalkIn ? CupertinoColors.activeOrange : CupertinoColors.label,
                    ),
                  ),
                  const Text(
                    '不绑定会员，无法使用积分和优惠券',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isWalkIn)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.activeOrange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final canStart = (_boundMember != null || _isWalkIn);

    return CupertinoButton.filled(
      borderRadius: BorderRadius.circular(14),
      onPressed: canStart ? _startOrder : null,
      child: const Text(
        '开始开单',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SalesTypeCard extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SalesTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0EDFF) : null,
          border: Border.all(
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.separator,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}