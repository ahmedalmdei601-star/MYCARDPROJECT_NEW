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
  bool rememberMe = false;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.lock_reset_rounded, color: primaryColor, size: 40),
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
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 96.0 : 28.0;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const _HeroHeader(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE4EAF3)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF173C76).withValues(alpha: .08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _LoginPanel(
                              identifierController: identifierController,
                              passwordController: passwordController,
                              passwordVisible: passwordVisible,
                              rememberMe: rememberMe,
                              loading: loading,
                              onRememberChanged: (value) => setState(() => rememberMe = value),
                              onPasswordVisibility: () => setState(() => passwordVisible = !passwordVisible),
                              onForgotPassword: showRecoveryNotice,
                              onLogin: login,
                              onCreateAccount: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen()),
                              ),
                            ),
                          ),
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

class _LoginPanel extends StatelessWidget {
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final bool rememberMe;
  final bool loading;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onPasswordVisibility;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  const _LoginPanel({
    required this.identifierController,
    required this.passwordController,
    required this.passwordVisible,
    required this.rememberMe,
    required this.loading,
    required this.onRememberChanged,
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
          'تسجيل الدخول',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          width: 190,
          height: 3,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 22),
        _LoginField(
          controller: identifierController,
          hint: 'البريد الإلكتروني أو رقم الهاتف',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
        ),
        const SizedBox(height: 13),
        _LoginField(
          controller: passwordController,
          hint: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscureText: !passwordVisible,
          leading: IconButton(
            tooltip: passwordVisible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
            onPressed: onPasswordVisibility,
            icon: Icon(
              passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: const Color(0xFF6C7791),
              size: 22,
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
        ),
        const SizedBox(height: 7),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (value) => onRememberChanged(value ?? false),
              activeColor: primaryColor,
              side: const BorderSide(color: primaryColor, width: 1.5),
              visualDensity: VisualDensity.compact,
            ),
            const Text(
              'تذكرني',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF27334F)),
            ),
            const Spacer(),
            TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        SizedBox(
          width: double.infinity,
          height: 53,
          child: ElevatedButton(
            onPressed: loading ? null : onLogin,
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'دخول',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 25),
                    ],
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: primaryColor.withValues(alpha: .24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFD9DFEC), thickness: 1)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('ليس لديك حساب؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF4B5873))),
            ),
            const Expanded(child: Divider(color: Color(0xFFD9DFEC), thickness: 1)),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onCreateAccount,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: const Size(0, 34),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationThickness: 1.2,
              color: primaryColor,
            ),
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
    return SizedBox(
      height: 58,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Color(0xFF475570)),
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Color(0xFF7A849B)),
          suffixIcon: Icon(icon, color: const Color(0xFF173C76), size: 23),
          prefixIcon: leading,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFE0E5EF), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: primaryColor, width: 1.7),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: errorColor, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: errorColor, width: 1.7),
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.45,
      child: ClipPath(
        clipper: _HeroWaveClipper(),
        child: CustomPaint(
          painter: _HeroPainter(),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(25, 15, 25, 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(flex: 7, child: _HeaderNetworkArt()),
                SizedBox(height: 2),
                _NetoraBrand(),
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
      children: [
        const Text(
          'NETORA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 1),
        const Text(
          'Network Manager',
          style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: .3),
        ),
      ],
    );
  }
}

class _HeaderNetworkArt extends StatelessWidget {
  const _HeaderNetworkArt();

  @override
  Widget build(BuildContext context) => const CustomPaint(painter: _HeaderNetworkPainter(), child: SizedBox.expand());
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF07326A), Color(0xFF0758AA), Color(0xFF0D76D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(size.width * .02, size.height * .2),
      size.height * .78,
      Paint()..color = const Color(0xFF4CC5FF).withValues(alpha: .11),
    );
    canvas.drawCircle(
      Offset(size.width * 1.05, size.height * .35),
      size.height * .72,
      Paint()..color = const Color(0xFF001B53).withValues(alpha: .18),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeaderNetworkPainter extends CustomPainter {
  const _HeaderNetworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .56);
    final r = math.min(size.width, size.height) * .22;
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, r, line);
    canvas.drawOval(Rect.fromCenter(center: center, width: r * .82, height: r * 2), line);
    canvas.drawOval(Rect.fromCenter(center: center, width: r * 2, height: r * .72), line);

    final nodes = Paint()..color = const Color(0xFF72D8FF);
    for (var i = 0; i < 9; i++) {
      final angle = i * math.pi * .43;
      final point = Offset(center.dx + math.cos(angle) * r * .92, center.dy + math.sin(angle) * r * .92);
      canvas.drawCircle(point, 3, nodes);
    }

    final wifi = Paint()
      ..color = const Color(0xFF55C8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .25),
        width: 48 + i * 28,
        height: 48 + i * 28,
      );
      canvas.drawArc(rect, math.pi * 1.18, math.pi * .64, false, wifi);
    }
    canvas.drawCircle(Offset(size.width * .5, size.height * .37), 9, Paint()..color = const Color(0xFF2DA7F7));

    final router = Rect.fromCenter(
      center: Offset(size.width * .5, size.height * .84),
      width: size.width * .5,
      height: size.height * .18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(router, const Radius.circular(14)),
      Paint()..color = const Color(0xFFF4F7FC),
    );
    final routerLine = Paint()
      ..color = const Color(0xFF163C73)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(router.left + 15, router.top + 4), Offset(router.left + 15, router.top - 42), routerLine);
    canvas.drawLine(Offset(router.right - 15, router.top + 4), Offset(router.right - 15, router.top - 42), routerLine);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(router.center.dx - 25 + i * 17, router.center.dy), 3.5, Paint()..color = const Color(0xFF2D9CEB));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * .83);
    path.cubicTo(size.width * .2, size.height * .98, size.width * .45, size.height * .65, size.width * .7, size.height * .84);
    path.cubicTo(size.width * .86, size.height * .95, size.width * .95, size.height * .81, size.width, size.height * .68);
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
                Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
                SizedBox(width: 7),
                Text(
                  'إدارة شبكتك بكل سهولة وأمان',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white),
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
    final path = Path()
      ..moveTo(0, size.height * .48)
      ..cubicTo(size.width * .24, size.height * .72, size.width * .51, size.height * .35, size.width, size.height * .6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = primaryColor);
    final edge = Path()
      ..moveTo(0, size.height * .4)
      ..cubicTo(size.width * .24, size.height * .64, size.width * .51, size.height * .27, size.width, size.height * .53)
      ..lineTo(size.width, size.height * .64)
      ..cubicTo(size.width * .51, size.height * .39, size.width * .24, size.height * .73, 0, size.height * .53)
      ..close();
    canvas.drawPath(edge, Paint()..color = const Color(0xFFDCE9FA));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
