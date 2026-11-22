import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> createNetworkOwner({
    required UserModel user,
    required String networkName,
    required String ownerEmail,
  }) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(user.id);
    // Use the owner UID as the network document ID so retries are idempotent
    // and never create a second network for the same owner.
    final networkRef = _firestore.collection('networks').doc(user.id);

    batch.set(userRef, {
      ...user.toMap(),
      'networkId': networkRef.id,
    });
    batch.set(networkRef, {
      'name': networkName,
      'ownerId': user.id,
      'ownerName': user.name,
      'ownerPhone': user.phone,
      'ownerEmail': ownerEmail,
      'role': 'Network Owner',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> updateLastLogin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<UserModel>> getClients() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'client')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
