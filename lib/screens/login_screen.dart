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
      final user = await AuthService.login(identifierController.text.trim(), passwordController.text.trim());
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
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo'))),
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
          builder: (context, constraints) => SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const _HeroHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                    child: _FormContent(
                      identifierController: identifierController,
                      passwordController: passwordController,
                      passwordVisible: passwordVisible,
                      loading: loading,
                      onPasswordVisibility: () => setState(() => passwordVisible = !passwordVisible),
                      onForgotPassword: showRecoveryNotice,
                      onLogin: login,
                      onCreateAccount: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen())),
                    ),
                  ),
                  const _SecurityFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final bool loading;
  final VoidCallback onPasswordVisibility;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  const _FormContent({
    required this.identifierController,
    required this.passwordController,
    required this.passwordVisible,
    required this.loading,
    required this.onPasswordVisibility,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('مرحباً بعودتك', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 31, height: 1.15, fontWeight: FontWeight.w800, color: primaryColor)),
        const SizedBox(height: 7),
        const Text('سجل الدخول للوصول إلى حسابك', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 19, color: Color(0xFF53658D))),
        const SizedBox(height: 24),
        _LoginField(
          controller: identifierController,
          label: 'رقم الهاتف',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
        ),
        const SizedBox(height: 13),
        _LoginField(
          controller: passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_rounded,
          obscureText: !passwordVisible,
          suffixIcon: IconButton(
            tooltip: passwordVisible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
            icon: Icon(passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFF65739A), size: 29),
            onPressed: onPasswordVisibility,
          ),
          validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(onPressed: onForgotPassword, child: const Text('هل نسيت كلمة المرور؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold, color: primaryColor))),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onLogin,
            icon: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.login_rounded, size: 31),
            label: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 5,
              shadowColor: primaryColor.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
            ),
          ),
        ),
        const SizedBox(height: 19),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFB7C9E8), thickness: 1.3)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('ليس لديك حساب؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 17, color: Color(0xFF53658D)))),
            const Expanded(child: Divider(color: Color(0xFFB7C9E8), thickness: 1.3)),
          ],
        ),
        TextButton.icon(
          onPressed: onCreateAccount,
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 29, color: primaryColor),
          label: const Text('إنشاء حساب جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 21, fontWeight: FontWeight.bold, color: primaryColor)),
        ),
      ],
    );
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?) validator;

  const _LoginField({required this.controller, required this.label, required this.icon, required this.validator, this.keyboardType, this.obscureText = false, this.suffixIcon});

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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: Color(0xFFC5D5EF), width: 1.4)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: primaryColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: errorColor, width: 1.4)),
      ),
      validator: validator,
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.12,
      child: ClipPath(
        clipper: _WaveClipper(),
        child: CustomPaint(
          painter: _HeroPainter(),
          child: const Row(
            children: [
              Expanded(flex: 11, child: _NetworkIllustration()),
              Expanded(flex: 10, child: _BrandLockup()),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18, top: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _LogoMark(size: 78),
          const SizedBox(height: 4),
          const FittedBox(fit: BoxFit.scaleDown, child: Text('NETORA', style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2))),
          const SizedBox(height: 2),
          const FittedBox(fit: BoxFit.scaleDown, child: Text('Network Management App', style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 0.2))),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size * .82, child: CustomPaint(painter: _LogoPainter(), child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w900)))));
  }
}

class _NetworkIllustration extends StatelessWidget {
  const _NetworkIllustration();

  @override
  Widget build(BuildContext context) => const CustomPaint(painter: _NetworkPainter(), child: SizedBox.expand());
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(colors: [Color(0xFF0878F4), Color(0xFF0751B1), Color(0xFF123A78)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(rect));
    canvas.drawCircle(Offset(size.width * .16, size.height * .22), size.height * .72, Paint()..color = const Color(0xFF55C9FF).withValues(alpha: .2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NetworkPainter extends CustomPainter {
  const _NetworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .45, size.height * .37);
    final radius = size.height * .3;
    final grid = Paint()..color = Colors.white.withValues(alpha: .28)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawCircle(center, radius, grid);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * .9, height: radius * 2), grid);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2, height: radius * .65), grid);

    final points = <Offset>[];
    final nodes = Paint()..color = const Color(0xFF75D8FF);
    for (var i = 0; i < 11; i++) {
      final angle = i * math.pi * .39;
      final point = Offset(center.dx + math.cos(angle) * radius * .9, center.dy + math.sin(angle) * radius * .9);
      points.add(point);
      canvas.drawCircle(point, 2.6, nodes);
      if (i > 0) canvas.drawLine(point, points[i - 1], Paint()..color = nodes.color.withValues(alpha: .45)..strokeWidth = .8);
    }

    final wifi = Paint()..color = Colors.white.withValues(alpha: .9)..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(center: Offset(size.width * .23, size.height * .29), width: 42 + i * 21, height: 42 + i * 21);
      canvas.drawArc(rect, math.pi * 1.18, math.pi * .64, false, wifi);
    }
    canvas.drawCircle(Offset(size.width * .23, size.height * .38), 5, Paint()..color = Colors.white);

    final router = Rect.fromCenter(center: Offset(size.width * .4, size.height * .75), width: size.width * .62, height: size.height * .21);
    canvas.drawRRect(RRect.fromRectAndRadius(router, const Radius.circular(12)), Paint()..shader = const LinearGradient(colors: [Color(0xFF102A43), Color(0xFF1F5A9C)]).createShader(router));
    final antenna = Paint()..color = const Color(0xFF102A43)..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(router.left + 22, router.top + 5), Offset(router.left + 22, router.top - 54), antenna);
    canvas.drawLine(Offset(router.right - 22, router.top + 5), Offset(router.right - 22, router.top - 54), antenna);
    for (var i = 0; i < 4; i++) canvas.drawCircle(Offset(router.center.dx - 30 + i * 20, router.center.dy), 4, Paint()..color = const Color(0xFF75D8FF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = Colors.white.withValues(alpha: .7)..style = PaintingStyle.stroke..strokeWidth = 1.3;
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

class _WaveClipper extends CustomClipper<Path> {
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

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: CustomPaint(
        painter: _FooterPainter(),
        child: const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 27),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('إدارة شبكتك بكل سهولة وأمان', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Color(0xFF65739A))),
                SizedBox(width: 8),
                Icon(Icons.verified_user_rounded, color: primaryColor, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = primaryColor;
    final light = Paint()..color = const Color(0xFFCFE0FA);
    final path = Path()..moveTo(0, size.height * .62)..cubicTo(size.width * .25, size.height * .78, size.width * .5, size.height * .45, size.width, size.height * .68)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, blue);
    final edge = Path()..moveTo(0, size.height * .55)..cubicTo(size.width * .25, size.height * .7, size.width * .5, size.height * .38, size.width, size.height * .61)..lineTo(size.width, size.height * .7)..cubicTo(size.width * .5, size.height * .46, size.width * .25, size.height * .78, 0, size.height * .63)..close();
    canvas.drawPath(edge, light);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
