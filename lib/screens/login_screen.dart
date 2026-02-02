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
  final _formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool loading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    
    try {
      final id = identifierController.text.trim();
      final pass = passwordController.text.trim();
      
      debugPrint('Attempting login for: $id');
      
      final user = await AuthService.login(id, pass);
      
      if (user != null) {
        debugPrint('Login successful: ${user.uid}');
        if (mounted) {
          // تحديث حالة المستخدم يدوياً لضمان الانتقال الفوري عبر RootScreen
          // RootScreen سيقوم تلقائياً بالتوجيه للوحة المناسبة بمجرد تحديث الحالة
          await Provider.of<UserState>(context, listen: false).refresh();
        }
      } else {
        throw Exception('فشل تسجيل الدخول، يرجى التحقق من البيانات.');
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.contains('invalid-credential')) {
          errorMessage = 'بيانات الدخول غير صحيحة.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: const TextStyle(fontFamily: 'Cairo')),
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Hero(
                    tag: 'logo',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.settings_input_antenna_rounded,
                              size: 60,
                              color: primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // App Title
                  Text(
                    isAr ? 'مدير الشبكات المحلية' : 'Local Network Manager',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'قم بتسجيل الدخول لإدارة شبكتك' : 'Sign in to manage your network',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Identifier Field
                  TextFormField(
                    controller: identifierController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      labelText: isAr ? 'رقم الهاتف أو البريد' : 'Phone or Email',
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isAr ? 'يرجى إدخال البيانات' : 'Please enter your details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      labelText: isAr ? 'كلمة المرور' : 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isAr ? 'يرجى إدخال كلمة المرور' : 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _rememberMe = val!),
                          ),
                          Text(
                            isAr ? 'تذكرني' : 'Remember me',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          isAr ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                          style: const TextStyle(color: primaryColor, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isAr ? 'تسجيل الدخول' : 'Login',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'LNM - v1.0',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
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
