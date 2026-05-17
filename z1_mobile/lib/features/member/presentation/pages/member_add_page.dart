import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/theme/app_theme.dart';

class MemberAddPage extends StatefulWidget {
  const MemberAddPage({super.key});

  @override
  State<MemberAddPage> createState() => _MemberAddPageState();
}

class _MemberAddPageState extends State<MemberAddPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _remarkController = TextEditingController();

  String _gender = 'unknown';
  DateTime? _birthday;
  bool _isLoading = false;

  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('新增会员'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildForm(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('基本信息'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          placeholder: '请输入姓名',
          prefix: '姓名',
          error: _nameError,
          onChanged: (_) => setState(() => _nameError = null),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          placeholder: '请输入手机号',
          prefix: '手机号',
          keyboardType: TextInputType.phone,
          error: _phoneError,
          onChanged: (_) => setState(() => _phoneError = null),
        ),
        const SizedBox(height: 16),
        _buildGenderSelector(),
        const SizedBox(height: 16),
        _buildBirthdayPicker(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _remarkController,
          placeholder: '选填',
          prefix: '备注',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.grey700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required String prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            prefix,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.grey800,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: controller,
                placeholder: placeholder,
                keyboardType: keyboardType,
                maxLines: maxLines,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: error != null ? AppTheme.errorColor : AppTheme.grey200),
                ),
                onChanged: onChanged,
              ),
              if (error != null) ...[
                const SizedBox(height: 4),
                Text(
                  error,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 70,
          child: Text(
            '性别',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.grey800,
            ),
          ),
        ),
        CupertinoSlidingSegmentedControl<String>(
          groupValue: _gender,
          children: const {
            'unknown': Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('未知'),
            ),
            'male': Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('男'),
            ),
            'female': Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('女'),
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              setState(() {
                _gender = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBirthdayPicker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 70,
          child: Text(
            '生日',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.grey800,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.grey200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _birthday != null
                        ? '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}'
                        : '选填',
                    style: TextStyle(
                      fontSize: 15,
                      color: _birthday != null ? AppTheme.grey800 : AppTheme.grey500,
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.calendar,
                    color: AppTheme.grey500,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('确认'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _birthday ?? DateTime(1990, 1, 1),
                onDateTimeChanged: (date) {
                  setState(() {
                    _birthday = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : const Text('保存'),
        ),
      ),
    );
  }

  bool _validate() {
    bool valid = true;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = '请输入姓名');
      valid = false;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _phoneError = '请输入手机号');
      valid = false;
    } else if (phone.length != 11) {
      setState(() => _phoneError = '手机号格式不正确');
      valid = false;
    }

    return valid;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = context.read<ApiClient>();
      final birthdayStr = _birthday != null
          ? '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}'
          : null;

      final result = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.memberAdd,
        data: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'gender': _gender,
          if (birthdayStr != null) 'birthday': birthdayStr,
          if (_remarkController.text.isNotEmpty) 'remark': _remarkController.text.trim(),
        },
        parser: (data) => data['data'] as Map<String, dynamic>,
      );

      if (!mounted) return;

      result.fold(
        (error) {
          _showError(error.message);
        },
        (data) {
          final memberId = data['id'] as int;
          context.pushReplacement('/member/$memberId');
        },
      );
    } catch (e) {
      if (mounted) {
        _showError('创建会员失败');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}