import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/card_services.dart';
import '../../services/auth_service.dart';
import '../../services/app_localizations.dart';
import '../../theme.dart';

class SendCardScreen extends StatefulWidget {
  const SendCardScreen({super.key});

  @override
  State<SendCardScreen> createState() => _SendCardScreenState();
}

class _SendCardScreenState extends State<SendCardScreen> {
  final _phoneController = TextEditingController();
  final _cardService = CardService();
  bool _loading = false;
  int? _selectedCategory;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCard() async {
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';
    final phone = _phoneController.text.trim();
    final currentUser = AuthService.currentUser;

    if (phone.isEmpty) {
      _showMsg(isAr ? 'الرجاء إدخال رقم هاتف الزبون' : 'Please enter customer phone', isError: true);
      return;
    }

    if (_selectedCategory == null) {
      _showMsg(isAr ? 'الرجاء اختيار فئة الكرت' : 'Please select a category', isError: true);
      return;
    }

    if (currentUser == null) return;

    setState(() => _loading = true);
    try {
      // Fetch available card for the selected category
      final card = await _cardService.getAvailableCard(currentUser.uid, value: _selectedCategory);
      
      if (card == null) {
        _showMsg(isAr ? 'عذراً، لا توجد كروت متاحة لهذه الفئة في مخزنك' : 'Sorry, no cards available for this category', isError: true);
        return;
      }

      final String cardCode = card['cardNumber'];
      final String provider = card['provider'];
      final String value = card['value'].toString();
      
      final String message = isAr 
          ? 'تم شراء كرت $provider فئة $value\nرقم الكرت: $cardCode\nشكراً لتعاملك معنا.'
          : 'Purchased $provider card, category $value\nCard Code: $cardCode\nThank you for choosing us.';

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        await _cardService.markCardAsUsed(cardCode, phone, currentUser.uid);
        _showMsg(isAr ? 'تم تجهيز الرسالة وفتح تطبيق الرسائل' : 'Message prepared, opening SMS app');
        _phoneController.clear();
        setState(() => _selectedCategory = null);
      } else {
        _showMsg(isAr ? 'فشل فتح تطبيق الرسائل' : 'Failed to open SMS app', isError: true);
      }
    } catch (e) {
      _showMsg(isAr ? 'حدث خطأ: $e' : 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String m, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.locale.languageCode == 'ar';
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l.translate('send_card'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(isAr ? 'بيانات العملية' : 'Transaction Details', Icons.send_to_mobile_outlined),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      isAr ? 'يرجى اختيار الفئة وإدخال رقم هاتف الزبون' : 'Please select category and enter customer phone',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black54, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 30),
                    
                    // Category Selection
                    if (currentUser != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('cards')
                            .where('ownerId', isEqualTo: currentUser.uid)
                            .where('status', isEqualTo: 'distributed')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const CircularProgressIndicator();
                          
                          // Get unique categories (values) available in inventory
                          Set<int> availableCategories = {};
                          for (var doc in snapshot.data!.docs) {
                            availableCategories.add(doc['value']);
                          }
                          
                          List<int> sortedCategories = availableCategories.toList()..sort();

                          return DropdownButtonFormField<int>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: isAr ? 'اختر فئة الكرت' : 'Select Category',
                              prefixIcon: const Icon(Icons.category_outlined, color: primaryColor),
                            ),
                            items: sortedCategories.map((val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Text(isAr ? 'فئة $val ريال' : 'Category $val Rial', style: const TextStyle(fontFamily: 'Cairo')),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Customer Phone Input
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: isAr ? 'رقم هاتف الزبون' : 'Customer Phone',
                        hintText: '7xxxxxxxx',
                        prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _sendCard,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: _loading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded),
                        label: Text(isAr ? 'إرسال الكرت الآن' : 'Send Card Now', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Helpful Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAr 
                        ? 'سيتم سحب كرت واحد من الفئة المختارة من مخزنك تلقائياً.'
                        : 'One card from the selected category will be automatically taken from your inventory.',
                      style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4, fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
