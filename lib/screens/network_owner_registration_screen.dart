import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';

class NetworkOwnerRegistrationScreen extends StatefulWidget {
  const NetworkOwnerRegistrationScreen({super.key});

  @override
  State<NetworkOwnerRegistrationScreen> createState() => _NetworkOwnerRegistrationScreenState();
}

class _NetworkOwnerRegistrationScreenState extends State<NetworkOwnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _networkNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _required(value, 'يرجى إدخال البريد الإلكتروني');
    if (required != null) return required;
    final email = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (value.length < 6) return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return 'يرجى تأكيد كلمة المرور';
    if (value != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await AuthService.createNetworkOwnerAccount(
        networkName: _networkNameController.text,
        ownerName: _ownerNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (user == null) throw Exception('تعذر إنشاء الحساب.');

      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الشبكة وحساب المالك بنجاح', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _networkNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('إنشاء شبكة جديدة'),
        leading: IconButton(
          tooltip: 'رجوع',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _loading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 700 ? 100.0 : 20.0;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _RegistrationHeader(),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE1E8F2)),
                            boxShadow: [
                              BoxShadow(
                                color: darkNavyColor.withValues(alpha: .07),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _RegistrationField(
                                controller: _networkNameController,
                                label: 'اسم الشبكة',
                                hint: 'مثال: شبكة النور',
                                icon: Icons.wifi_rounded,
                                validator: (value) => _required(value, 'يرجى إدخال اسم الشبكة'),
                              ),
                              const SizedBox(height: 14),
                              _RegistrationField(
                                controller: _ownerNameController,
                                label: 'اسم مالك الشبكة',
                                hint: 'الاسم الكامل',
                                icon: Icons.person_outline_rounded,
                                validator: (value) => _required(value, 'يرجى إدخال اسم المالك'),
                              ),
                              const SizedBox(height: 14),
                              _RegistrationField(
                                controller: _phoneController,
                                label: 'رقم الهاتف',
                                hint: 'رقم التواصل مع المالك',
                                icon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (value) => _required(value, 'يرجى إدخال رقم الهاتف'),
                              ),
                              const SizedBox(height: 14),
                              _RegistrationField(
                                controller: _emailController,
                                label: 'البريد الإلكتروني',
                                hint: 'example@email.com',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),
                              _RegistrationField(
                                controller: _passwordController,
                                label: 'كلمة المرور',
                                hint: '6 أحرف على الأقل',
                                icon: Icons.lock_outline_rounded,
                                obscureText: !_passwordVisible,
                                suffix: _VisibilityButton(
                                  visible: _passwordVisible,
                                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 14),
                              _RegistrationField(
                                controller: _confirmPasswordController,
                                label: 'تأكيد كلمة المرور',
                                hint: 'أعد كتابة كلمة المرور',
                                icon: Icons.verified_user_outlined,
                                obscureText: !_confirmPasswordVisible,
                                suffix: _VisibilityButton(
                                  visible: _confirmPasswordVisible,
                                  onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                                ),
                                validator: _validateConfirmation,
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Icon(Icons.add_business_rounded, size: 22),
                                            SizedBox(width: 9),
                                            Text(
                                              'إنشاء الشبكة والحساب',
                                              style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'سيتم حفظ بيانات الشبكة وربطها بحساب المالك بشكل آمن.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(0xFF6B7890)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryColor, vibrantBlueColor]),
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(color: primaryColor.withValues(alpha: .22), blurRadius: 16, offset: const Offset(0, 7)),
            ],
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 14),
        const Text(
          'إنشاء شبكة جديدة',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 25, fontWeight: FontWeight.w800, color: darkNavyColor),
        ),
        const SizedBox(height: 5),
        const Text(
          'أنشئ حساب مالك الشبكة وابدأ بإدارة شبكتك بسهولة',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF68758D), height: 1.5),
        ),
      ],
    );
  }
}

class _RegistrationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?) validator;

  const _RegistrationField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: darkNavyColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF66748D)),
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFFA0AABB)),
        suffixIcon: Icon(icon, color: primaryColor, size: 22),
        prefixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E7F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const _VisibilityButton({required this.visible, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: visible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
      onPressed: onPressed,
      icon: Icon(visible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFF6A7892), size: 21),
    );
  }
}
