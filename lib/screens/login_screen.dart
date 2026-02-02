import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_state.dart';
import '../services/app_localizations.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _isPasswordVisible = false;

  Future<void> login() async {
    final l = AppLocalizations.of(context);
    final errorMsg = l != null ? (l.locale.languageCode == 'ar' ? 'الرجاء إدخال اسم المستخدم وكلمة المرور' : 'Please enter username and password') : 'الرجاء إدخال اسم المستخدم وكلمة المرور';

    if (identifierController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => loading = true);
    
    Provider.of<UserState>(context, listen: false).clearState();

    try {
      await AuthService.login(
        identifierController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
    final isAr = l?.locale.languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_tethering,
                    size: 80,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  isAr ? 'مرحباً بك' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 10),
                Text(
                  isAr ? 'قم بتسجيل الدخول لإدارة شبكتك' : 'Sign in to manage your network',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 50),

                // Identifier Input (Phone or Email)
                TextField(
                  controller: identifierController,
                  keyboardType: TextInputType.emailAddress, // Changed to support @ and dots
                  decoration: InputDecoration(
                    labelText: isAr ? 'رقم الهاتف أو البريد' : 'Phone or Email',
                    hintText: isAr ? 'أدخل بيانات الدخول الخاصة بك' : 'Enter your login details',
                    prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: isAr ? 'كلمة المرور' : 'Password',
                    hintText: isAr ? 'أدخل كلمة المرور' : 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(isAr ? 'تسجيل الدخول' : 'Login'),
                  ),
                ),
                const SizedBox(height: 40),
                
                Text(
                  isAr ? 'نظام إدارة الشبكات المحلية للبقالات' : 'Local Grocery Network Management System',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
