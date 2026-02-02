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
  bool _initializingAuth = true; // Added to track initial auth state check

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
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedInLocally = prefs.getBool('isLoggedIn') ?? false;

    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUser(firebaseUser.uid);
        await prefs.setBool('isLoggedIn', true);
      } else {
        _user = null;
        _errorMessage = null;
        _isLoading = false;
        await prefs.setBool('isLoggedIn', false);
        notifyListeners();
      }
      _initializingAuth = false; // Auth state check is complete
    });

    // If Firebase auth state changes listener hasn't completed and no local session,
    // ensure isLoading is set to false after a short delay to prevent indefinite loading.
    // This handles cases where Firebase might not trigger authStateChanges immediately for unauthenticated users.
    if (_initializingAuth && !isLoggedInLocally) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_initializingAuth) {
          _isLoading = false;
          notifyListeners();
          _initializingAuth = false;
        }
      });
    }
  }

  Future<void> _loadUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = await _userService.getUser(uid);
      
      if (userData != null && (userData.role == 'admin' || userData.role == 'client')) {
        _user = userData;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
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
      _isLoading = true;
      notifyListeners();
      
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all shared preferences on logout
      
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during sign out: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUser(currentUser.uid);
    } else {
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
