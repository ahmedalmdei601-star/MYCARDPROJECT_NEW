import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    if (locale.languageCode == 'ar') {
      _localizedStrings = {
        "app_title": "تطبيق إدارة الكروت",
        "admin_dashboard": "لوحة التحكم",
        "welcome_admin": "مرحباً المسؤول",
        "network_summary": "إليك ملخص إدارة الشبكة اليوم",
        "manage_groceries": "إدارة البقالات",
        "manage_groceries_sub": "عرض وحذف وإضافة",
        "add_cards": "إضافة كروت",
        "add_cards_sub": "إدخال كروت الشبكة",
        "distribute_cards": "توزيع كروت",
        "distribute_cards_sub": "توزيع على البقالات",
        "reports": "التقارير",
        "reports_sub": "المبيعات والاستخدام",
        "settings": "الإعدادات",
        "about_us": "حولنا",
        "logout": "تسجيل الخروج",
        "language": "لغة التطبيق",
        "dark_mode": "الوضع الداكن",
        "change_password": "تغيير كلمة المرور",
        "save": "حفظ",
        "cancel": "إلغاء",
        "close": "إغلاق",
        "new_password": "كلمة المرور الجديدة",
        "password_hint": "أدخل 6 أحرف على الأقل",
        "confirm_delete": "تأكيد الحذف",
        "delete_msg": "هل أنت متأكد من الحذف نهائياً؟",
        "delete": "حذف",
        "add_grocery": "إضافة بقالة",
        "my_store": "متجري",
        "welcome": "مرحباً",
        "client_summary": "إليك نظرة سريعة على كروتك وعملياتك",
        "send_card": "إرسال كرت",
        "send_card_sub": "بيع كرت لعميل",
        "my_cards": "كروتي",
        "my_cards_sub": "الكروت المتاحة في المخزن",
        "history": "السجل",
        "history_sub": "سجل عمليات البيع",
        "settings_sub": "اللغة، المظهر، وكلمة المرور",
        "store_account": "حساب البقالة"
      };
    } else {
      _localizedStrings = {
        "app_title": "Card Management App",
        "admin_dashboard": "Admin Dashboard",
        "welcome_admin": "Welcome Admin",
        "network_summary": "Here is your network summary today",
        "manage_groceries": "Manage Groceries",
        "manage_groceries_sub": "View, Delete, and Add",
        "add_cards": "Add Cards",
        "add_cards_sub": "Input network cards",
        "distribute_cards": "Distribute Cards",
        "distribute_cards_sub": "Distribute to groceries",
        "reports": "Reports",
        "reports_sub": "Sales and Usage",
        "settings": "Settings",
        "about_us": "About Us",
        "logout": "Logout",
        "language": "App Language",
        "dark_mode": "Dark Mode",
        "change_password": "Change Password",
        "save": "Save",
        "cancel": "Cancel",
        "close": "Close",
        "new_password": "New Password",
        "password_hint": "Enter at least 6 characters",
        "confirm_delete": "Confirm Delete",
        "delete_msg": "Are you sure you want to delete permanently?",
        "delete": "Delete",
        "add_grocery": "Add Grocery",
        "my_store": "My Store",
        "welcome": "Welcome",
        "client_summary": "Here is a quick look at your cards and operations",
        "send_card": "Send Card",
        "send_card_sub": "Sell a card to a customer",
        "my_cards": "My Cards",
        "my_cards_sub": "Available cards in stock",
        "history": "History",
        "history_sub": "Sales operations history",
        "settings_sub": "Language, Theme & Password",
        "store_account": "Store Account"
      };
    }
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
