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
      if (mounted) {
        await Provider.of<UserState>(context, listen: false).refresh();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 72.0 : 20.0;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const _HeroHeader(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
                      child: _FormContent(
                        identifierController: identifierController,
                        passwordController: passwordController,
                        passwordVisible: passwordVisible,
                        loading: loading,
                        onPasswordVisibility: () => setState(() => passwordVisible = !passwordVisible),
                        onForgotPassword: showRecoveryNotice,
                        onLogin: login,
                        onCreateAccount: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen()),
                        ),
                      ),
                    ),
                    const _SecurityFooter(),
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
        const Text(
          'مرحباً بعودتك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'سجل الدخول للوصول إلى حسابك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            height: 1.4,
            color: Color(0xFF65708A),
          ),
        ),
        const SizedBox(height: 28),
        _LoginField(
          controller: identifierController,
          hint: 'رقم الهاتف',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
        ),
        const SizedBox(height: 17),
        _LoginField(
          controller: passwordController,
          hint: 'كلمة المرور',
          icon: Icons.lock_rounded,
          obscureText: !passwordVisible,
          leading: IconButton(
            tooltip: passwordVisible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
            onPressed: onPasswordVisibility,
            icon: Icon(
              passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: const Color(0xFF667493),
              size: 28,
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'هل نسيت كلمة المرور؟',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 70,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onLogin,
            icon: loading
                ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.login_rounded, size: 34),
            label: const Text(
              'تسجيل الدخول',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 7,
              shadowColor: primaryColor.withValues(alpha: .3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
            ),
          ),
        ),
        const SizedBox(height: 27),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFC1CEE4), thickness: 1.4)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'ليس لديك حساب؟',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 17, color: Color(0xFF65708A)),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFC1CEE4), thickness: 1.4)),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onCreateAccount,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            foregroundColor: primaryColor,
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 31),
          label: const Text(
            'إنشاء حساب جديد',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? leading;
  final String? Function(String?) validator;

  const _LoginField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, color: Color(0xFF53617C)),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 20, color: Color(0xFF65708A)),
        suffixIcon: Icon(icon, color: primaryColor, size: 31),
        prefixIcon: leading,
        filled: true,
        fillColor: const Color(0xFFF4F6FD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(31),
          borderSide: const BorderSide(color: Color(0xFFC8D7EC), width: 1.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(31),
          borderSide: const BorderSide(color: primaryColor, width: 2.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(31),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(31),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
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
      aspectRatio: 1.42,
      child: ClipPath(
        clipper: _WaveClipper(),
        child: CustomPaint(
          painter: _HeroPainter(),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(18, 12, 12, 24),
            child: Row(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: _BrandLockup()),
                Expanded(flex: 12, child: _NetworkIllustration()),
              ],
            ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LogoMark(size: 86),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: const Text(
            'NETORA',
            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
        ),
        const SizedBox(height: 2),
        const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Network Management App',
            style: TextStyle(color: Colors.white70, fontSize: 12.5, letterSpacing: .2),
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * .82,
      child: CustomPaint(
        painter: _LogoPainter(),
        child: Center(
          child: Text(
            'N',
            style: TextStyle(color: Colors.white, fontSize: size * .52, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
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
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF168CF5), Color(0xFF0870D6), Color(0xFF063D8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(size.width * .17, size.height * .18),
      size.height * .76,
      Paint()..color = const Color(0xFF65D4FF).withValues(alpha: .18),
    );
    canvas.drawCircle(
      Offset(size.width * .98, size.height * .25),
      size.height * .8,
      Paint()..color = const Color(0xFF001E62).withValues(alpha: .2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NetworkPainter extends CustomPainter {
  const _NetworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .55, size.height * .43);
    final radius = math.min(size.width, size.height) * .31;
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, grid);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * .95, height: radius * 2), grid);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2, height: radius * .72), grid);

    final nodes = Paint()..color = const Color(0xFF77D9FF);
    final points = <Offset>[];
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi * .34;
      final point = Offset(center.dx + math.cos(angle) * radius * .92, center.dy + math.sin(angle) * radius * .92);
      points.add(point);
      canvas.drawCircle(point, 3.1, nodes);
      if (i > 0) {
        canvas.drawLine(
          point,
          points[i - 1],
          Paint()
            ..color = nodes.color.withValues(alpha: .45)
            ..strokeWidth = .9,
        );
      }
    }

    final wifi = Paint()
      ..color = Colors.white.withValues(alpha: .95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final arc = Rect.fromCenter(
        center: Offset(size.width * .54, size.height * .18),
        width: 56 + i * 25,
        height: 56 + i * 25,
      );
      canvas.drawArc(arc, math.pi * 1.18, math.pi * .64, false, wifi);
    }
    canvas.drawCircle(Offset(size.width * .54, size.height * .28), 5.5, Paint()..color = Colors.white);

    final router = Rect.fromCenter(
      center: Offset(size.width * .56, size.height * .78),
      width: size.width * .72,
      height: size.height * .2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(router, const Radius.circular(18)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF102D4B), Color(0xFF174F7D)],
        ).createShader(router),
    );
    final antenna = Paint()
      ..color = const Color(0xFF092846)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(router.left + 25, router.top + 8), Offset(router.left + 25, router.top - 75), antenna);
    canvas.drawLine(Offset(router.right - 25, router.top + 8), Offset(router.right - 25, router.top - 75), antenna);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(router.center.dx - 35 + i * 24, router.center.dy),
        4.5,
        Paint()..color = const Color(0xFF78D8FF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final dot = Paint()..color = Colors.white;
    final points = [
      Offset(size.width * .12, size.height * .2),
      Offset(size.width * .86, size.height * .26),
      Offset(size.width * .78, size.height * .82),
      Offset(size.width * .18, size.height * .74),
    ];
    for (var i = 0; i < points.length; i++) {
      canvas.drawLine(points[i], points[(i + 1) % points.length], line);
      canvas.drawCircle(points[i], 3.7, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * .87);
    path.cubicTo(size.width * .2, size.height * .73, size.width * .43, size.height * .98, size.width * .67, size.height * .85);
    path.cubicTo(size.width * .84, size.height * .76, size.width * .94, size.height * .82, size.width, size.height * .63);
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
      height: 124,
      child: CustomPaint(
        painter: _FooterPainter(),
        child: const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_rounded, color: Colors.white, size: 25),
                SizedBox(width: 8),
                Text(
                  'إدارة شبكتك بكل سهولة وأمان',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Colors.white),
                ),
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
    final path = Path()
      ..moveTo(0, size.height * .54)
      ..cubicTo(size.width * .25, size.height * .74, size.width * .5, size.height * .42, size.width, size.height * .64)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, blue);
    final edge = Path()
      ..moveTo(0, size.height * .47)
      ..cubicTo(size.width * .25, size.height * .66, size.width * .5, size.height * .34, size.width, size.height * .57)
      ..lineTo(size.width, size.height * .66)
      ..cubicTo(size.width * .5, size.height * .43, size.width * .25, size.height * .75, 0, size.height * .58)
      ..close();
    canvas.drawPath(edge, light);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
