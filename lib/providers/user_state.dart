import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';

class UserState extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  bool _initializingAuth = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';
  bool get isAuthenticated => _user != null;

  UserState() {
    _init();
  }

  Future<void> _init() async {
    // 1. استرجاع حالة الجلسة المحفوظة محلياً (إذا كانت موجودة)
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // إذا كانت هناك جلسة محفوظة، نبقى في حالة التحميل حتى ينتهي Firebase من التحقق
    _isLoading = isLoggedIn;
    notifyListeners();

    // 2. الاستماع لحالة المصادقة من Firebase
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // إذا كان مسجل دخول في Firebase، نحمل بياناته
        await _loadUser(firebaseUser.uid);
        await prefs.setBool('isLoggedIn', true);
      } else {
        // إذا لم يكن مسجلاً، نصفر الحالة فقط إذا لم نكن في مرحلة التهيئة
        if (!_initializingAuth) {
          _user = null;
          _errorMessage = null;
          _isLoading = false;
          await prefs.setBool('isLoggedIn', false);
          notifyListeners();
        } else {
          // إذا لم تكن هناك جلسة في Firebase أثناء التهيئة
          _user = null;
          _isLoading = false;
          await prefs.setBool('isLoggedIn', false);
          notifyListeners();
        }
      }
      _initializingAuth = false;
    });
  }

  Future<void> _loadUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = await _userService.getUser(uid);
      
      if (userData != null && (userData.role == 'admin' || userData.role == 'client')) {
        _user = userData;
      } else {
        _user = null;
        _errorMessage = 'صلاحيات المستخدم غير معرفة في النظام.';
      }
    } catch (e) {
      debugPrint('Error loading user data from Firestore: $e');
      _user = null;
      _errorMessage = 'فشل جلب بيانات الصلاحيات من الخادم.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  void clearState() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUser(currentUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }
}
