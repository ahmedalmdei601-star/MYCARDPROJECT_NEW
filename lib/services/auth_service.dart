import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_services.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final UserService _userService = UserService();

  // Helper to convert phone to a valid email format for Firebase Auth
  static String _identifierToEmail(String identifier) {
    if (identifier.contains('@')) {
      return identifier.trim();
    }
    // If it's just a phone number or digits, convert to dummy email
    return '${identifier.trim()}@mycardproject.app';
  }

  // Admin-only function to create client accounts
  static Future<User?> createClientAccount({
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: _identifierToEmail(phone),
        password: password,
      );

      if (cred.user != null) {
        // 2. Create user document in Firestore
        await _userService.createUser(UserModel(
          id: cred.user!.uid,
          name: name,
          phone: phone,
          role: 'client', // Always create as 'client'
          createdAt: DateTime.now(),
        ));
        
        return cred.user;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'خطأ في إنشاء الحساب.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'رقم الهاتف هذا مسجل بالفعل.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'صيغة رقم الهاتف غير صحيحة.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'كلمة المرور ضعيفة جداً.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'فشل الاتصال بالإنترنت.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
    return null;
  }

  // Public registration for a new network owner. A secondary Firebase app
  // keeps the current session untouched while creating the new account.
  static Future<User?> createNetworkOwnerAccount({
    required String networkName,
    required String ownerName,
    required String phone,
    required String email,
    required String password,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      try {
        secondaryApp = Firebase.app('NetworkOwnerRegistration');
      } catch (_) {
        secondaryApp = await Firebase.initializeApp(
          name: 'NetworkOwnerRegistration',
          options: Firebase.app().options,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;

      await _userService.createNetworkOwner(
        user: UserModel(
          id: user.uid,
          name: ownerName.trim(),
          phone: phone.trim(),
          role: 'Network Owner',
          createdAt: DateTime.now(),
          email: email.trim(),
          networkName: networkName.trim(),
        ),
        networkName: networkName.trim(),
        ownerEmail: email.trim(),
      );

      await secondaryAuth.signOut();
      return user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'خطأ في إنشاء حساب مالك الشبكة.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'البريد الإلكتروني مستخدم بالفعل.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'صيغة البريد الإلكتروني غير صحيحة.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'كلمة المرور ضعيفة جداً.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'فشل الاتصال بالإنترنت.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء إنشاء الشبكة: $e');
    } finally {
      await secondaryApp?.delete();
    }
  }

  // Login for all users (supports phone or email)
  static Future<User?> login(
    String identifier,
    String password,
  ) async {
    try {
      final email = _identifierToEmail(identifier);
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        // Update lastLogin in Firestore
        await _userService.updateLastLogin(cred.user!.uid);
      }
      return cred.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'خطأ في تسجيل الدخول.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'فشل الاتصال بالإنترنت.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'تم حظر المحاولات مؤقتاً بسبب نشاط مشبوه. حاول لاحقاً.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // Function for users to change their own password
  static Future<void> changePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
      // بعد تغيير كلمة المرور بنجاح، يجب تسجيل الخروج فوراً لضمان الأمان
      await _auth.signOut();
    } else {
      throw Exception('لم يتم العثور على مستخدم مسجل.');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current authenticated user
  static User? get currentUser => _auth.currentUser;
}
