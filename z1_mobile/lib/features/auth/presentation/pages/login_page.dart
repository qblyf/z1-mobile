import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController(text: '99999999999');
  final _passwordController = TextEditingController(text: 'ncxSEpbZ\$20m\$W6O');
  final _passwordFocusNode = FocusNode();
  final _loginFocusNode = FocusNode();
  bool _rememberMe = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _loginFocusNode.dispose();
    super.dispose();
  }

  void _onLogin() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      _showError('请输入账号和密码');
      return;
    }

    context.read<AuthBloc>().add(AuthLoginRequested(
          mobilePhone: phone,
          password: password,
          rememberMe: _rememberMe,
        ));
  }

  /// 处理键盘事件（用于 Playwright 自动化测试）
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Enter 键触发登录
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        _onLogin();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('提示'),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _showError(state.message);
        } else if (state is AuthAuthenticated) {
          // 登录成功，跳转到主页
          context.go('/home');
        }
      },
      child: Focus(
        // 全局键盘监听，支持 Enter 键触发登录
        onKeyEvent: _handleKeyEvent,
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Logo 和标题
                  const Center(
                    child: Column(
                      children: [
                        Image(
                          image: AssetImage('assets/images/logo.png'),
                          width: 80,
                          height: 80,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '掌上高远',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '企业管理',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 手机号输入
                  CupertinoTextField(
                    controller: _phoneController,
                    placeholder: '请输入账号',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(CupertinoIcons.phone),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 密码输入
                  CupertinoTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    placeholder: '请输入密码',
                    obscureText: _isObscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLogin(), // 密码框回车触发登录
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(CupertinoIcons.lock),
                    ),
                    suffix: GestureDetector(
                      onTap: () => setState(() => _isObscure = !_isObscure),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          _isObscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 记住我
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            Icon(
                              _rememberMe
                                  ? CupertinoIcons.checkmark_square_fill
                                  : CupertinoIcons.square,
                              color: _rememberMe
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.secondaryLabel,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '记住我',
                              style: TextStyle(color: CupertinoColors.secondaryLabel),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // 登录按钮
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return CupertinoButton.filled(
                        focusNode: _loginFocusNode,
                        onPressed: isLoading ? null : _onLogin,
                        borderRadius: BorderRadius.circular(12),
                        child: isLoading
                            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                            : const Text(
                                '登录',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      );
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}