import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/app_localizations.dart';
import '../../theme.dart';

class ClientInventoryScreen extends StatelessWidget {
  const ClientInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l.translate('my_cards'))),
      body: currentUser == null
          ? Center(child: Text(isAr ? 'يرجى تسجيل الدخول' : 'Please Login'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cards')
                  .where('ownerId', isEqualTo: currentUser.uid)
                  .where('status', isEqualTo: 'distributed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          isAr ? 'مخزنك فارغ حالياً' : 'Your inventory is empty',
                          style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isAr ? 'تواصل مع المسؤول لتزويدك بالكروت' : 'Contact admin to get cards',
                          style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // Group cards by provider
                Map<String, List<Map<String, dynamic>>> groupedStats = {};
                for (var doc in docs) {
                  String provider = doc['provider'] ?? 'Unknown';
                  int value = doc['value'] ?? 0;
                  
                  if (!groupedStats.containsKey(provider)) {
                    groupedStats[provider] = [];
                  }
                  
                  // Check if this value already exists for this provider
                  int existingIndex = groupedStats[provider]!.indexWhere((item) => item['value'] == value);
                  if (existingIndex != -1) {
                    groupedStats[provider]![existingIndex]['count'] += 1;
                  } else {
                    groupedStats[provider]!.add({
                      'value': value,
                      'count': 1,
                    });
                  }
                }

                // Sort values within each provider
                for (var provider in groupedStats.keys) {
                  groupedStats[provider]!.sort((a, b) => a['value'].compareTo(b['value']));
                }

                final providers = groupedStats.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    final stats = groupedStats[provider]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.business, color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                provider,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...stats.map((item) => _buildInventoryCard(
                          context,
                          provider: provider,
                          value: item['value'].toString(),
                          count: item['count'].toString(),
                          isAr: isAr,
                        )),
                        if (index < providers.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(thickness: 2, color: primaryColor),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, {required String provider, required String value, required String count, required bool isAr}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.style_outlined, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'فئة $value ريال' : 'Category $value Rial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                Text(
                  isAr ? 'كرت' : 'Cards',
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
