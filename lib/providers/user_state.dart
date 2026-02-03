import 'dart:convert';
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
    _isLoading = true;
    notifyListeners();

    // 1. Try to load saved user from SharedPreferences for immediate access
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('saved_user');
      if (savedUserJson != null) {
        _user = UserModel.fromJson(jsonDecode(savedUserJson));
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved user: $e');
    }

    // 2. Listen for Firebase Auth state changes to sync with server
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // If Firebase indicates a user is logged in, refresh their data from Firestore
        await _loadUser(firebaseUser.uid);
      } else {
        // If Firebase indicates no user, clear local state and storage
        await _clearLocalSession();
      }
    });

    // 3. Perform an immediate check for the current user to handle app startup
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUser(currentUser.uid);
    } else {
      if (_user == null) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _clearLocalSession() async {
    _user = null;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
    await prefs.remove('isLoggedIn');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUser(String uid) async {
    // Only set loading to true if we don't already have a user (from local storage)
    if (_user == null) {
      _isLoading = true;
      notifyListeners();
    }
    
    _errorMessage = null;

    try {
      final userData = await _userService.getUser(uid);
      
      if (userData != null && (userData.role == 'admin' || userData.role == 'client')) {
        _user = userData;
        // Save to local storage for next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_user', jsonEncode(userData.toJson()));
        await prefs.setBool('isLoggedIn', true);
      } else {
        _user = null;
        _errorMessage = 'صلاحيات المستخدم غير معرفة في النظام.';
        await _clearLocalSession();
      }
    } catch (e) {
      debugPrint('Error loading user data from Firestore: $e');
      // If we already have a user from local storage, don't clear it on network error
      if (_user == null) {
        _errorMessage = 'فشل جلب بيانات الصلاحيات من الخادم.';
      }
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
      await _clearLocalSession();
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
