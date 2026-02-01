import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("إدارة البقالات"),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("خطأ: ${snapshot.error}"));
          }
          final clients = snapshot.data ?? [];
          if (clients.isEmpty) {
            return const Center(
              child: Text(
                "لا توجد بقالات مسجلة حالياً",
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
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
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    client.phone,
                    style: const TextStyle(fontFamily: 'Cairo'),
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
        label: const Text(
          "إضافة بقالة",
          style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "تأكيد الحذف",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Text(
          "هل أنت متأكد من حذف البقالة '${client.name}' نهائياً من النظام؟",
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(fontFamily: 'Cairo')),
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
                        "تم حذف البقالة بنجاح",
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
                        "خطأ في الحذف: $e",
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text(
              "حذف",
              style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
