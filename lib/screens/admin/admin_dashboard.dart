import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_state.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/app_localizations.dart';
import '../../theme.dart';
import 'add_cards_screen.dart';
import 'distribute_screen.dart';
import 'reports_screen.dart';
import 'manage_groceries_screen.dart';
import 'settings_screen.dart';
import 'admin_cards_screen.dart';
import '../login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _handleLogout(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isAr ? 'تسجيل الخروج' : 'Logout',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAr ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to logout?',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isAr ? 'خروج' : 'Logout',
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userState = Provider.of<UserState>(context, listen: false);
      await userState.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l.translate('admin_dashboard')),
      ),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Welcome Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.translate('welcome_admin'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.translate('network_summary'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.85,
                    children: [
                      _buildMenuCard(
                        context,
                        title: l.translate('manage_groceries'),
                        subtitle: l.translate('manage_groceries_sub'),
                        icon: Icons.storefront_outlined,
                        color: Colors.blue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageGroceriesScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: l.translate('add_cards'),
                        subtitle: l.translate('add_cards_sub'),
                        icon: Icons.add_card_outlined,
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardsScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: isAr ? 'عرض الكروت' : 'View Cards',
                        subtitle: isAr ? 'فرز حسب الفئة والحالة' : 'Sort by category & status',
                        icon: Icons.style_outlined,
                        color: Colors.indigo,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCardsScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: l.translate('distribute_cards'),
                        subtitle: l.translate('distribute_cards_sub'),
                        icon: Icons.move_to_inbox_outlined,
                        color: Colors.teal,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributeScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: l.translate('reports'),
                        subtitle: isAr ? 'سجل التوزيع والإحصائيات' : 'Distribution & Stats',
                        icon: Icons.analytics_outlined,
                        color: Colors.purple,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: l.translate('settings'),
                        subtitle: isAr ? 'اللغة والمظهر' : 'Lang & Theme',
                        icon: Icons.settings_outlined,
                        color: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryColor),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: primaryColor, size: 40),
            ),
            accountName: Text(
              l.translate('welcome_admin'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            accountEmail: const Text("Admin Panel", style: TextStyle(fontFamily: 'Cairo')),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.storefront_outlined,
                  title: l.translate('manage_groceries'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageGroceriesScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.add_card_outlined,
                  title: l.translate('add_cards'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardsScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.style_outlined,
                  title: isAr ? 'عرض الكروت' : 'View Cards',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCardsScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.move_to_inbox_outlined,
                  title: l.translate('distribute_cards'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributeScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.analytics_outlined,
                  title: l.translate('reports'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: l.translate('settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: l.translate('logout'),
                  color: Colors.red,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
