import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';

/// 登录页 - iOS 风格
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    if (rememberMe) {
      setState(() {
        _rememberMe = true;
        _accountController.text = prefs.getString(AppConstants.savedAccountKey) ?? '';
        _passwordController.text = prefs.getString(AppConstants.savedPasswordKey) ?? '';
      });
    }
  }

  Future<void> _saveCredentials(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setBool(AppConstants.rememberMeKey, true);
      await prefs.setString(AppConstants.savedAccountKey, _accountController.text.trim());
      await prefs.setString(AppConstants.savedPasswordKey, _passwordController.text);
    } else {
      await prefs.setBool(AppConstants.rememberMeKey, false);
      await prefs.remove(AppConstants.savedAccountKey);
      await prefs.remove(AppConstants.savedPasswordKey);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    // 简单验证
    if (_accountController.text.trim().isEmpty) {
      _showError('请输入正确的账号');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('请输入密码');
      return;
    }

    // 保存凭据
    _saveCredentials(_rememberMe);

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            account: _accountController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            AppRouter.goHome(context);
          } else if (state.status == AuthStatus.failure) {
            _showError(state.errorMessage ?? '登录失败');
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(
                    CupertinoIcons.shopping_cart,
                    size: 80,
                    color: CupertinoColors.activeBlue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Z1 全网连锁',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '登录到您的账号',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 手机号输入
                  CupertinoTextField(
                    controller: _accountController,
                    placeholder: '账号/手机号',
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        CupertinoIcons.phone,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 密码输入
                  CupertinoTextField(
                    controller: _passwordController,
                    placeholder: '密码',
                    obscureText: _obscurePassword,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        CupertinoIcons.lock,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLogin(),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 记住密码
                  Row(
                    children: [
                      CupertinoSwitch(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text('记住密码'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 登录按钮
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : _onLogin,
                          child: state.status == AuthStatus.loading
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                )
                              : const Text('登录'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}