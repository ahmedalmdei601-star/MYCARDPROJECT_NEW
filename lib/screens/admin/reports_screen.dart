import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import '../../theme.dart';
import '../../services/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(isAr ? 'التقارير والإحصائيات' : 'Reports & Stats'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
            tabs: [
              Tab(text: isAr ? 'إحصائيات الكروت' : 'Card Stats'),
              Tab(text: isAr ? 'سجل التوزيع' : 'Distribution History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCardStats(isAr),
            _buildDistributionList(isAr),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionList(bool isAr) {
    // We remove the .orderBy('distributedAt') to avoid the need for a composite index
    // and instead sort the list in memory if needed, or just rely on status filter.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cards')
          .where('status', isEqualTo: 'distributed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                Text(
                  isAr ? 'لا توجد عمليات توزيع مسجلة حالياً' : 'No distribution records found',
                  style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                ),
              ],
            ),
          );
        }

        // Sort in memory to avoid Firebase Index requirement
        final sortedDocs = List.from(docs);
        sortedDocs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['distributedAt'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['distributedAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime); // Descending
        });

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            final doc = sortedDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['distributedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(data['ownerId']).get(),
              builder: (context, userSnap) {
                String clientName = isAr ? 'تحميل...' : 'Loading...';
                if (userSnap.hasData && userSnap.data!.exists) {
                  final userData = userSnap.data!.data() as Map<String, dynamic>;
                  clientName = userData['name'] ?? 'Unknown';
                }

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: Colors.orange, size: 20),
                    ),
                    title: Text(
                      "${isAr ? 'إلى' : 'To'}: $clientName",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['provider']} - فئة ${data['value']}",
                          style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                        ),
                        Text(
                          intl.DateFormat('yyyy-MM-dd HH:mm').format(date),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCardStats(bool isAr) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cards').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        int available = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'available').length;
        int distributed = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'distributed').length;
        int used = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'used').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'ملخص حالة الكروت' : 'Card Status Summary',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 20),
              
              _buildModernStatCard(isAr ? 'كروت في النظام' : 'In System', available, Icons.inventory_2, Colors.green),
              const SizedBox(height: 16),
              _buildModernStatCard(isAr ? 'كروت موزعة' : 'Distributed', distributed, Icons.storefront, Colors.orange),
              const SizedBox(height: 16),
              _buildModernStatCard(isAr ? 'كروت مباعة' : 'Sold', used, Icons.sell, Colors.blue),
              
              const SizedBox(height: 40),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isAr ? 'إجمالي الكروت في النظام' : 'Total Cards in System',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${docs.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Cairo'),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
