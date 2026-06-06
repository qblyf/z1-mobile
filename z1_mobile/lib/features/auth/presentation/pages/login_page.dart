import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 测试凭据通过 --dart-define=TEST_PHONE=xxx --dart-define=TEST_PWD=xxx 注入，
  // 不写进源码、不入 git；未注入时为空，正常手动输入。
  final _phoneController = TextEditingController(
    text: const String.fromEnvironment('TEST_PHONE'),
  );
  final _passwordController = TextEditingController(
    text: const String.fromEnvironment('TEST_PWD'),
  );
  bool _rememberMe = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
                  placeholder: '请输入密码',
                  obscureText: _isObscure,
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
    );
  }
}