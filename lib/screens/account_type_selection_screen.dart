import 'package:flutter/material.dart';

import '../theme.dart';
import 'register_screen.dart';
import 'network_owner_registration_screen.dart';

class AccountTypeSelectionScreen extends StatelessWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('اختيار نوع الحساب'),
        leading: IconButton(
          tooltip: 'رجوع',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded, color: primaryColor, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'اختر نوع الحساب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: darkNavyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'حدد نوع الحساب الذي ترغب في إنشائه للمتابعة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    _AccountTypeCard(
                      icon: Icons.hub_rounded,
                      title: 'إنشاء شبكة جديدة',
                      description: 'أنا صاحب شبكة',
                      accentColor: vibrantBlueColor,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NetworkOwnerRegistrationScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AccountTypeCard(
                      icon: Icons.storefront_rounded,
                      title: 'الانضمام إلى شبكة',
                      description: 'أنا صاحب بقالة',
                      accentColor: primaryColor,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('العودة إلى تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo')),
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

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: accentColor.withOpacity(0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accentColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkNavyColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 18, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
