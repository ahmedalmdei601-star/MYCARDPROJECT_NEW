import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_state.dart';
import '../services/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'account_type_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool _isPasswordVisible = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final user = await AuthService.login(
        identifierController.text.trim(),
        passwordController.text.trim(),
      );

      if (user == null) {
        throw Exception('بيانات الدخول غير صحيحة.');
      }

      if (mounted) {
        await Provider.of<UserState>(context, listen: false).refresh();
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showRecoveryNotice() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.lock_reset_rounded, color: primaryColor, size: 42),
        title: const Text(
          'استعادة كلمة المرور',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'إذا كان الحساب يستخدم رقم هاتف اصطناعياً، تواصل مع مسؤول النظام لإعادة تعيين كلمة المرور مع الحفاظ على الحساب الحالي.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', height: 1.6),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l?.locale.languageCode != 'en';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBrandHeader(),
                      const SizedBox(height: 34),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          isAr ? 'مرحباً بعودتك' : 'Welcome back',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: darkNavyColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          isAr ? 'سجل الدخول للوصول إلى حسابك.' : 'Sign in to access your account.',
                          style: const TextStyle(fontFamily: 'Cairo', color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 26),
                      TextFormField(
                        controller: identifierController,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        decoration: InputDecoration(
                          labelText: isAr ? 'رقم الهاتف' : 'Phone number',
                          prefixIcon: const Icon(Icons.phone_outlined, color: primaryColor),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? (isAr ? 'يرجى إدخال رقم الهاتف' : 'Enter your phone number')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        decoration: InputDecoration(
                          labelText: isAr ? 'كلمة المرور' : 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: primaryColor),
                          suffixIcon: IconButton(
                            tooltip: _isPasswordVisible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? (isAr ? 'يرجى إدخال كلمة المرور' : 'Enter your password')
                            : null,
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _showRecoveryNotice,
                          child: Text(
                            isAr ? 'هل نسيت كلمة المرور؟' : 'Forgot password?',
                            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: loading ? null : login,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  isAr ? 'تسجيل الدخول' : 'Sign in',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isAr ? 'ليس لديك حساب؟' : "Don't have an account?",
                            style: const TextStyle(fontFamily: 'Cairo', color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen()),
                            ),
                            child: Text(
                              isAr ? 'إنشاء حساب جديد' : 'Create a new account',
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [darkNavyColor, vibrantBlueColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.24),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              'assets/icons/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'NETORA',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: darkNavyColor,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Network Management App',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, letterSpacing: 0.5, color: vibrantBlueColor),
        ),
      ],
    );
  }
}
