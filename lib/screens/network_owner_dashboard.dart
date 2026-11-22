import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_state.dart';
import '../theme.dart';

class NetworkOwnerDashboard extends StatelessWidget {
  const NetworkOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    final networkName = user?.networkName?.trim();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('لوحة مالك الشبكة'),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<UserState>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [darkNavyColor, primaryColor],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: darkNavyColor.withValues(alpha: .18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.hub_rounded, color: Colors.white, size: 36),
                  const SizedBox(height: 18),
                  Text(
                    'مرحباً ${user?.name ?? ''}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    networkName?.isNotEmpty == true ? networkName! : 'شبكتك الجديدة',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Icon(Icons.verified_rounded, color: primaryColor, size: 42),
                    const SizedBox(height: 12),
                    const Text(
                      'تم تسجيل الدخول بنجاح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: darkNavyColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'حساب مالك الشبكة جاهز. سيتم إضافة أدوات إدارة الشبكة في لوحة التحكم القادمة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.black54, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
