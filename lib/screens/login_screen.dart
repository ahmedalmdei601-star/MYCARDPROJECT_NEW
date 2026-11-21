import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_state.dart';
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
  bool passwordVisible = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final user = await AuthService.login(
        identifierController.text.trim(),
        passwordController.text.trim(),
      );
      if (user == null) throw Exception('بيانات الدخول غير صحيحة.');
      if (mounted) await Provider.of<UserState>(context, listen: false).refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showRecoveryNotice() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.lock_reset_rounded, color: primaryColor, size: 42),
        title: const Text('استعادة كلمة المرور', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const _ReferenceHero(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                      child: _LoginContent(
                        identifierController: identifierController,
                        passwordController: passwordController,
                        passwordVisible: passwordVisible,
                        loading: loading,
                        onPasswordVisibilityChanged: () => setState(() => passwordVisible = !passwordVisible),
                        onForgotPassword: showRecoveryNotice,
                        onLogin: login,
                        onCreateAccount: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final bool loading;
  final VoidCallback onPasswordVisibilityChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  const _LoginContent({
    required this.identifierController,
    required this.passwordController,
    required this.passwordVisible,
    required this.loading,
    required this.onPasswordVisibilityChanged,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'مرحباً بعودتك',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 31, height: 1.15, fontWeight: FontWeight.w800, color: primaryColor),
        ),
        const SizedBox(height: 7),
        const Text(
          'سجل الدخول للوصول إلى حسابك',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 19, height: 1.3, color: Color(0xFF53658D)),
        ),
        const SizedBox(height: 24),
        _ReferenceField(
          controller: identifierController,
          label: 'رقم الهاتف',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
        ),
        const SizedBox(height: 13),
        _ReferenceField(
          controller: passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_rounded,
          obscureText: !passwordVisible,
          suffixIcon: IconButton(
            tooltip: passwordVisible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
            icon: Icon(passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 29, color: const Color(0xFF65739A)),
            onPressed: onPasswordVisibilityChanged,
          ),
          validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: onForgotPassword,
            child: const Text('هل نسيت كلمة المرور؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold, color: primaryColor)),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onLogin,
            icon: loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.login_rounded, size: 31),
            label: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 5,
              shadowColor: primaryColor.withOpacity(0.35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
            ),
          ),
        ),
        const SizedBox(height: 19),
        Row(
          children: [
            Expanded(child: Divider(color: const Color(0xFFB7C9E8), thickness: 1.3)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('ليس لديك حساب؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 17, color: Color(0xFF53658D))),
            ),
            Expanded(child: Divider(color: const Color(0xFFB7C9E8), thickness: 1.3)),
          ],
        ),
        TextButton.icon(
          onPressed: onCreateAccount,
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 29, color: primaryColor),
          label: const Text('إنشاء حساب جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 21, fontWeight: FontWeight.bold, color: primaryColor)),
        ),
        const SizedBox(height: 19),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_rounded, color: primaryColor, size: 26),
            SizedBox(width: 8),
            Text('إدارة شبكتك بكل سهولة وأمان', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Color(0xFF65739A))),
          ],
        ),
      ],
    );
  }
}

class _ReferenceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?) validator;

  const _ReferenceField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Color(0xFF53658D)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 19, color: Color(0xFF65739A)),
        prefixIcon: Icon(icon, color: primaryColor, size: 29),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF1F6FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFC5D5EF), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: errorColor, width: 1.4),
        ),
      ),
      validator: validator,
    );
  }
}

class _ReferenceHero extends StatelessWidget {
  const _ReferenceHero();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.1,
      child: ClipPath(
        clipper: _HeroClipper(),
        child: CustomPaint(
          painter: _HeroPainter(),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 22, 28),
            child: Row(
              children: [
                Expanded(flex: 11, child: _RouterScene()),
                Expanded(flex: 10, child: _NetoraBrand()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetoraBrand extends StatelessWidget {
  const _NetoraBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _NetworkLogo(size: 76),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text('NETORA', style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        ),
        const SizedBox(height: 2),
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Network Management App', style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 0.2)),
        ),
      ],
    );
  }
}

class _NetworkLogo extends StatelessWidget {
  final double size;
  const _NetworkLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size * 0.82, child: CustomPaint(painter: _LogoPainter(), child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w900)))));
  }
}

class _RouterScene extends StatelessWidget {
  const _RouterScene();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _RouterScenePainter(), child: SizedBox.expand());
  }
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(colors: [Color(0xFF086FEA), Color(0xFF06499C), Color(0xFF103875)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(rect));
    final glow = Paint()..color = const Color(0xFF54C6FF).withOpacity(0.24);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), size.height * 0.7, glow);
    final wave = Paint()..color = Colors.white.withOpacity(0.18)..style = PaintingStyle.stroke..strokeWidth = 1.4;
    final path = Path()..moveTo(0, size.height * 0.78)..cubicTo(size.width * 0.22, size.height * 0.62, size.width * 0.46, size.height * 0.94, size.width * 0.72, size.height * 0.76)..cubicTo(size.width * 0.88, size.height * 0.65, size.width * 0.95, size.height * 0.74, size.width, size.height * 0.58);
    canvas.drawPath(path, wave);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RouterScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final globeCenter = Offset(size.width * 0.47, size.height * 0.39);
    final radius = size.height * 0.31;
    final globePaint = Paint()..color = Colors.white.withOpacity(0.28)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawCircle(globeCenter, radius, globePaint);
    canvas.drawOval(Rect.fromCenter(center: globeCenter, width: radius * 0.9, height: radius * 2), globePaint);
    canvas.drawOval(Rect.fromCenter(center: globeCenter, width: radius * 2, height: radius * 0.65), globePaint);

    final nodePaint = Paint()..color = const Color(0xFF75D8FF);
    final nodes = <Offset>[];
    for (var i = 0; i < 10; i++) {
      final angle = i * math.pi * 0.43;
      final node = Offset(globeCenter.dx + math.cos(angle) * radius * 0.9, globeCenter.dy + math.sin(angle) * radius * 0.9);
      nodes.add(node);
      canvas.drawCircle(node, 2.4, nodePaint);
      if (i > 0) canvas.drawLine(node, nodes[i - 1], Paint()..color = nodePaint.withOpacity(0.42)..strokeWidth = 0.8);
    }

    final wifi = Paint()..color = Colors.white.withOpacity(0.9)..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(center: Offset(size.width * 0.25, size.height * 0.3), width: 42 + i * 22, height: 42 + i * 22);
      canvas.drawArc(rect, math.pi * 1.18, math.pi * 0.64, false, wifi);
    }
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.38), 5, Paint()..color = Colors.white);

    final routerRect = Rect.fromCenter(center: Offset(size.width * 0.42, size.height * 0.75), width: size.width * 0.62, height: size.height * 0.22);
    final routerPaint = Paint()..shader = const LinearGradient(colors: [Color(0xFF102A43), Color(0xFF1F5A9C)]).createShader(routerRect);
    canvas.drawRRect(RRect.fromRectAndRadius(routerRect, const Radius.circular(12)), routerPaint);
    final antenna = Paint()..color = const Color(0xFF102A43)..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(routerRect.left + 22, routerRect.top + 6), Offset(routerRect.left + 22, routerRect.top - 55), antenna);
    canvas.drawLine(Offset(routerRect.right - 22, routerRect.top + 6), Offset(routerRect.right - 22, routerRect.top - 55), antenna);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(routerRect.center.dx - 30 + i * 20, routerRect.center.dy), 4, Paint()..color = const Color(0xFF75D8FF));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = Colors.white.withOpacity(0.7)..style = PaintingStyle.stroke..strokeWidth = 1.3;
    final dot = Paint()..color = Colors.white;
    final points = [Offset(size.width * .15, size.height * .2), Offset(size.width * .84, size.height * .26), Offset(size.width * .78, size.height * .8), Offset(size.width * .18, size.height * .73)];
    for (var i = 0; i < points.length; i++) {
      canvas.drawLine(points[i], points[(i + 1) % points.length], line);
      canvas.drawCircle(points[i], 3.2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * .84);
    path.cubicTo(size.width * .2, size.height * .67, size.width * .45, size.height * .98, size.width * .7, size.height * .82);
    path.cubicTo(size.width * .86, size.height * .71, size.width * .94, size.height * .79, size.width, size.height * .6);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
