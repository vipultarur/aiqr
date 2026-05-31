import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiqr_app/models/user_model.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Type-safe Collection Reference
  CollectionReference<UserModel> get _userCollection =>
      _firestore.collection('users').withConverter<UserModel>(
            fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
            toFirestore: (user, _) => user.toJson(),
          );

  /// Save or Update User Data
  Future<void> saveUserData(UserModel user) async {
    try {
      await _userCollection.doc(user.uid).set(user, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      AppLogger.error('Firestore save failed: ${e.message}', e);
      throw Exception('Firestore Error: ${e.message}');
    }
  }

  /// Get User Future
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _userCollection.doc(uid).get();
      return doc.data();
    } catch (e) {
      AppLogger.error('Firestore get user failed: $e', e);
      return null;
    }
  }

  /// Real-time User Stream
  Stream<UserModel?> getUserStream(String uid) {
    return _userCollection.doc(uid).snapshots().map((snapshot) => snapshot.data());
  }
}
