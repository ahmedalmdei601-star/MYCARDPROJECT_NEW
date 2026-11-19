import 'dart:math' as math;

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

      if (user == null) throw Exception('بيانات الدخول غير صحيحة.');
      if (mounted) await Provider.of<UserState>(context, listen: false).refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontFamily: 'Cairo')),
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
    final isAr = AppLocalizations.of(context)?.locale.languageCode != 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const _NetoraHeroHeader(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Column(
                          children: [
                            const Text(
                              'مرحباً بعودتك',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 31, fontWeight: FontWeight.w800, color: primaryColor, height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'سجل الدخول للوصول إلى حسابك',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 19, color: Color(0xFF53658D), height: 1.3),
                            ),
                            const SizedBox(height: 26),
                            _buildField(
                              controller: identifierController,
                              label: isAr ? 'رقم الهاتف' : 'Phone number',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? (isAr ? 'يرجى إدخال رقم الهاتف' : 'Enter your phone number')
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              controller: passwordController,
                              label: isAr ? 'كلمة المرور' : 'Password',
                              icon: Icons.lock_rounded,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                tooltip: _isPasswordVisible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: const Color(0xFF65739A),
                                  size: 28,
                                ),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? (isAr ? 'يرجى إدخال كلمة المرور' : 'Enter your password')
                                  : null,
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: _showRecoveryNotice,
                                child: const Text(
                                  'هل نسيت كلمة المرور؟',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton.icon(
                                onPressed: loading ? null : login,
                                icon: loading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.login_rounded, size: 30),
                                label: Text(
                                  'تسجيل الدخول',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shadowColor: primaryColor.withOpacity(0.35),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(child: Divider(color: primaryColor.withOpacity(0.25), thickness: 1.5)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Text('ليس لديك حساب؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 17, color: Color(0xFF53658D))),
                                ),
                                Expanded(child: Divider(color: primaryColor.withOpacity(0.25), thickness: 1.5)),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen()),
                              ),
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 29),
                              label: const Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user_rounded, color: primaryColor, size: 26),
                                SizedBox(width: 8),
                                Text('إدارة شبكتك بكل سهولة وأمان', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Color(0xFF65739A))),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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

class _NetoraHeroHeader extends StatelessWidget {
  const _NetoraHeroHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 294,
      width: double.infinity,
      child: ClipPath(
        clipper: _HeroWaveClipper(),
        child: CustomPaint(
          painter: _HeroNetworkPainter(),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _RouterIllustration()),
                SizedBox(width: 10),
                Expanded(child: _BrandLockup()),
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
      children: [
        Container(
          width: 82,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withOpacity(0.14),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: const _NetworkLogoMark(),
        ),
        const SizedBox(height: 12),
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('NETORA', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 3),
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Network Management App', style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 0.4)),
        ),
      ],
    );
  }
}

class _RouterIllustration extends StatelessWidget {
  const _RouterIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 12, child: Icon(Icons.wifi_rounded, color: Colors.white.withOpacity(0.9), size: 70)),
          Positioned(
            bottom: 24,
            child: Container(
              width: 150,
              height: 62,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF102A43), Color(0xFF1D4E89)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (_) => Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(color: Color(0xFF6EA8FE), shape: BoxShape.circle),
                )),
              ),
            ),
          ),
          Positioned(bottom: 78, left: 36, child: Container(width: 5, height: 58, color: const Color(0xFF102A43))),
          Positioned(bottom: 78, right: 36, child: Container(width: 5, height: 58, color: const Color(0xFF102A43))),
        ],
      ),
    );
  }
}

class _NetworkLogoMark extends StatelessWidget {
  const _NetworkLogoMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NetworkLogoPainter(),
      child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, height: 1))),
    );
  }
}

class _NetworkLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final nodePaint = Paint()..color = Colors.white;
    final nodes = <Offset>[
      Offset(size.width * 0.16, size.height * 0.2),
      Offset(size.width * 0.84, size.height * 0.25),
      Offset(size.width * 0.78, size.height * 0.8),
      Offset(size.width * 0.18, size.height * 0.75),
    ];
    for (var i = 0; i < nodes.length; i++) {
      canvas.drawLine(nodes[i], nodes[(i + 1) % nodes.length], linePaint);
      canvas.drawCircle(nodes[i], 3.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroNetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = const LinearGradient(
      colors: [Color(0xFF0B5ED7), Color(0xFF064A9B), Color(0xFF102A43)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final glowPaint = Paint()..color = const Color(0xFF51B6FF).withOpacity(0.22);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), size.height * 0.55, glowPaint);

    final globeCenter = Offset(size.width * 0.24, size.height * 0.33);
    final globeRadius = size.height * 0.25;
    final globePaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(globeCenter, globeRadius, globePaint);
    canvas.drawOval(Rect.fromCenter(center: globeCenter, width: globeRadius * 0.95, height: globeRadius * 2), globePaint);
    canvas.drawOval(Rect.fromCenter(center: globeCenter, width: globeRadius * 2, height: globeRadius * 0.72), globePaint);

    final nodePaint = Paint()..color = const Color(0xFF83D7FF);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final node = Offset(globeCenter.dx + math.cos(angle) * globeRadius, globeCenter.dy + math.sin(angle) * globeRadius);
      canvas.drawCircle(node, 2.5, nodePaint);
    }

    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()..moveTo(0, size.height * 0.77);
    path.cubicTo(size.width * 0.24, size.height * 0.67, size.width * 0.48, size.height * 0.9, size.width * 0.72, size.height * 0.75);
    path.cubicTo(size.width * 0.85, size.height * 0.67, size.width * 0.94, size.height * 0.75, size.width, size.height * 0.67);
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * 0.86);
    path.cubicTo(size.width * 0.22, size.height * 0.72, size.width * 0.48, size.height * 0.98, size.width * 0.72, size.height * 0.83);
    path.cubicTo(size.width * 0.86, size.height * 0.74, size.width * 0.94, size.height * 0.78, size.width, size.height * 0.62);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
