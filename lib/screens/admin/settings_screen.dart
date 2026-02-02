import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/app_localizations.dart';
import '../../theme.dart';
import '../login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l.translate('settings')),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(l.translate('language')),
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('العربية', style: TextStyle(fontFamily: 'Cairo')),
                      value: 'ar',
                      groupValue: settings.locale.languageCode,
                      activeColor: primaryColor,
                      onChanged: (val) => settings.setLocale('ar'),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('English', style: TextStyle(fontFamily: 'Cairo')),
                      value: 'en',
                      groupValue: settings.locale.languageCode,
                      activeColor: primaryColor,
                      onChanged: (val) => settings.setLocale('en'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l.translate('dark_mode')),
              Card(
                child: SwitchListTile(
                  secondary: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: primaryColor),
                  title: Text(l.translate('dark_mode'), style: const TextStyle(fontFamily: 'Cairo')),
                  value: settings.isDarkMode,
                  activeColor: primaryColor,
                  onChanged: (bool value) {
                    settings.toggleTheme();
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l.translate('change_password')),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline, color: primaryColor),
                  title: Text(l.translate('change_password'), style: const TextStyle(fontFamily: 'Cairo')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.translate('change_password'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l.translate('new_password'),
              hintText: l.translate('password_hint'),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return l.translate('password_hint');
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.translate('cancel'), style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await AuthService.changePassword(passwordController.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.translate('save'), style: const TextStyle(fontFamily: 'Cairo'))),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: Text(l.translate('save'), style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
