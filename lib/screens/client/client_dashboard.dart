import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/user_state.dart';
import '../../services/app_localizations.dart';
import '../../theme.dart';
import 'send_card_screen.dart';
import 'client_inventory_screen.dart';
import 'client_history_screen.dart';
import '../admin/settings_screen.dart';
import '../login_screen.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

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
    final userState = Provider.of<UserState>(context);
    final userName = userState.user?.name ?? (l.locale.languageCode == 'ar' ? "صاحب البقالة" : "Store Owner");

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l.translate('my_store')),
      ),
      drawer: _buildDrawer(context, userName),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Client Header
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
                        "${l.translate('welcome')}, $userName",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.translate('client_summary'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
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
                        title: l.translate('send_card'),
                        subtitle: l.translate('send_card_sub'),
                        icon: Icons.send_to_mobile_outlined,
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendCardScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: l.translate('my_cards'),
                        subtitle: l.translate('my_cards_sub'),
                        icon: Icons.inventory_2_outlined,
                        color: Colors.teal,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientInventoryScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: l.translate('history'),
                        subtitle: l.translate('history_sub'),
                        icon: Icons.history_edu_outlined,
                        color: Colors.blue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientHistoryScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: l.translate('settings'),
                        subtitle: l.translate('settings_sub'),
                        icon: Icons.settings_outlined,
                        color: Colors.purple,
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

  Widget _buildDrawer(BuildContext context, String userName) {
    final l = AppLocalizations.of(context)!;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryColor),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.storefront, color: primaryColor, size: 40),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            accountEmail: Text(l.translate('store_account'), style: const TextStyle(fontFamily: 'Cairo')),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.send_to_mobile_outlined,
                  title: l.translate('send_card'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SendCardScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: l.translate('my_cards'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientInventoryScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history_edu_outlined,
                  title: l.translate('history'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientHistoryScreen()));
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
                  icon: Icons.info_outline,
                  title: l.translate('about_us'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                const Divider(),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "My Card Project",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(Icons.wifi_tethering, color: primaryColor),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "نظام إدارة وتوزيع كروت الشبكة المحلية للبقالات.",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "يهدف هذا التطبيق إلى تسهيل وتنظيم عملية توزيع كروت الشبكة المحلية لأصحاب البقالات والمحلات التجارية، حيث يوفر منصة متكاملة لإدارة المخزون، وتتبع المبيعات، وتوزيع الكروت للعملاء بكل سهولة وأمان. يسعى النظام إلى أتمتة العمليات اليدوية وتقليل الأخطاء وضمان وصول الخدمة للمستخدمين بكفاءة عالية.",
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          "تم تطوير هذا التطبيق بواسطة المهندس أحمد المدي ومجموعة من المهندسين الآخرين.",
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.email_outlined, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            const Text(
              "ahmedalmdei@gmail.com",
              style: TextStyle(fontSize: 13, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }
}
