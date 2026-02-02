import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import '../../services/app_localizations.dart';
import '../../theme.dart';
import '../register_screen.dart';

class ManageGroceriesScreen extends StatefulWidget {
  const ManageGroceriesScreen({super.key});

  @override
  State<ManageGroceriesScreen> createState() => _ManageGroceriesScreenState();
}

class _ManageGroceriesScreenState extends State<ManageGroceriesScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l.translate('manage_groceries')),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final clients = snapshot.data ?? [];
          if (clients.isEmpty) {
            return Center(
              child: Text(
                "No groceries found",
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.storefront, color: primaryColor),
                  ),
                  title: Text(
                    client.name,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    client.phone,
                    style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, client),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l.translate('add_grocery'),
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel client) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l.translate('confirm_delete'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Text(
          "${l.translate('delete_msg')} '${client.name}'",
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.translate('cancel'), style: const TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userService.deleteUser(client.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Success",
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error: $e",
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              l.translate('delete'),
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
