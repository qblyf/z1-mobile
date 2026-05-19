import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/result.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';

class MemberCreditscoreEditPage extends StatefulWidget {
  final int memberId;

  const MemberCreditscoreEditPage({super.key, required this.memberId});

  @override
  State<MemberCreditscoreEditPage> createState() => _MemberCreditscoreEditPageState();
}

class _MemberCreditscoreEditPageState extends State<MemberCreditscoreEditPage> {
  bool _isIncrease = true;
  final _creditController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  int _lastSubmittedCredit = 0;

  @override
  void dispose() {
    _creditController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final creditText = _creditController.text.trim();
    final reason = _reasonController.text.trim();

    if (creditText.isEmpty) {
      setState(() => _errorMessage = '请输入调整积分值');
      return;
    }

    final creditValue = int.tryParse(creditText);
    if (creditValue == null || creditValue <= 0) {
      setState(() => _errorMessage = '请输入有效的正整数积分值');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final adjustValue = _isIncrease ? creditValue : -creditValue;

      final result = await apiClient.post(
        '/members/creditscore/adjust',
        data: {
          'userIdents': widget.memberId,
          'adjustValue': adjustValue,
          'reason': reason,
        },
      );

      if (result is Success) {
        _lastSubmittedCredit = creditValue;
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        final failure = (result as Failure).failure;
        setState(() {
          _errorMessage = failure.message;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('调整成功'),
        content: Text('积分已${_isIncrease ? '增加' : '减少'} $_lastSubmittedCredit'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('积分调整'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('调整类型', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIncrease = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isIncrease ? AppTheme.successColor.withOpacity(0.1) : AppTheme.grey100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isIncrease ? AppTheme.successColor : AppTheme.grey300,
                                width: _isIncrease ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.add,
                                  color: _isIncrease ? AppTheme.successColor : AppTheme.grey600,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '增加积分',
                                  style: TextStyle(
                                    color: _isIncrease ? AppTheme.successColor : AppTheme.grey600,
                                    fontWeight: _isIncrease ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIncrease = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isIncrease ? AppTheme.errorColor.withOpacity(0.1) : AppTheme.grey100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !_isIncrease ? AppTheme.errorColor : AppTheme.grey300,
                                width: !_isIncrease ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.minus,
                                  color: !_isIncrease ? AppTheme.errorColor : AppTheme.grey600,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '减少积分',
                                  style: TextStyle(
                                    color: !_isIncrease ? AppTheme.errorColor : AppTheme.grey600,
                                    fontWeight: !_isIncrease ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('调整积分值', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _creditController,
                    placeholder: '请输入积分值（正整数）',
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '单位：积分（1积分 = 0.01元）',
                    style: TextStyle(color: AppTheme.grey500, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('调整原因', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _reasonController,
                    placeholder: '请输入调整原因（选填）',
                    maxLines: 3,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.exclamationmark_circle, color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: TextStyle(color: AppTheme.errorColor)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : const Text('确认调整'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}