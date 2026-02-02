import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_state.dart';
import 'providers/card_state.dart';
import 'providers/settings_provider.dart';
import 'services/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/client/client_dashboard.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized");
  } catch (e) {
    debugPrint("Initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => CardState()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return MaterialApp(
      title: 'مدير الشبكات المحلية',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      home: const SplashScreen(),
      builder: _errorWidgetBuilder,
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    // 1. حالة التحميل الأولية: نبقى في شاشة بيضاء أو مؤشر تحميل بسيط 
    // لكي لا تظهر شاشة تسجيل الدخول للحظات
    if (userState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    // 2. إذا كان هناك خطأ صريح
    if (userState.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  userState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => userState.signOut(),
                  child: const Text('العودة لتسجيل الدخول', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. التوجيه بناءً على حالة المصادقة
    if (!userState.isAuthenticated) {
      return const LoginScreen();
    }

    // 4. التوجيه بناءً على الدور (Role)
    if (userState.isAdmin) {
      return const AdminDashboard();
    }

    if (userState.isClient) {
      return const ClientDashboard();
    }

    // حالة احتياطية
    return const LoginScreen();
  }
}

Widget _errorWidgetBuilder(BuildContext context, Widget? widget) {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'حدث خطأ غير متوقع:\n${details.exception}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  };
  return widget!;
}
