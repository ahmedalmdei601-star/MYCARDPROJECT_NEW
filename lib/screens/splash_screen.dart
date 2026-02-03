import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import to access RootScreen
import '../theme.dart';
import '../providers/user_state.dart'; // Import UserState

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Listen to UserState changes to determine when to navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserState>(context, listen: false).addListener(_handleUserStateChange);
    });
  }

  void _handleUserStateChange() {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoading && mounted) {
      // UserState has finished loading, navigate to RootScreen
      userState.removeListener(_handleUserStateChange);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Ensure listener is removed to prevent memory leaks
    Provider.of<UserState>(context, listen: false).removeListener(_handleUserStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Professional Network Icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.settings_input_antenna_rounded,
                        size: 80,
                        color: primaryColor,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'مدير الشبكات المحلية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const Text(
                'Local Network Manager',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'مرحباً بك في نظام الإدارة',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
