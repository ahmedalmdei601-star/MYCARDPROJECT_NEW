import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/app_localizations.dart';
import '../../theme.dart';

class AdminCardsScreen extends StatefulWidget {
  const AdminCardsScreen({super.key});

  @override
  State<AdminCardsScreen> createState() => _AdminCardsScreenState();
}

class _AdminCardsScreenState extends State<AdminCardsScreen> {
  String _selectedStatus = 'all'; // all, available, distributed, used
  
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(isAr ? 'عرض الكروت' : 'View Cards')),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', isAr ? 'الكل' : 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('available', isAr ? 'في النظام' : 'In System'),
                  const SizedBox(width: 8),
                  _buildFilterChip('distributed', isAr ? 'موزعة' : 'Distributed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('used', isAr ? 'مباعة' : 'Sold'),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      isAr ? 'لا توجد كروت تطابق الفلتر' : 'No cards match filter',
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // Group by Provider and Value
                Map<String, Map<String, dynamic>> stats = {};
                for (var doc in docs) {
                  String provider = doc['provider'] ?? 'Unknown';
                  int value = doc['value'] ?? 0;
                  String key = '$provider-$value';
                  
                  if (!stats.containsKey(key)) {
                    stats[key] = {
                      'provider': provider,
                      'value': value,
                      'count': 0,
                    };
                  }
                  stats[key]!['count'] += 1;
                }

                final sortedKeys = stats.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final item = stats[sortedKeys[index]]!;
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.style_outlined, color: primaryColor),
                        ),
                        title: Text(
                          "${item['provider']} - فئة ${item['value']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${item['count']} كرت",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    bool isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontFamily: 'Cairo', color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: primaryColor,
      onSelected: (selected) {
        if (selected) setState(() => _selectedStatus = status);
      },
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    var query = FirebaseFirestore.instance.collection('cards');
    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus) as CollectionReference<Map<String, dynamic>>;
    }
    return query.snapshots();
  }
}
