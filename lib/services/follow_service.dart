import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('follows');

  static String _addressId(String address) =>
      address.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').substring(
          0, address.length.clamp(0, 100));

  static Future<bool> isFollowing(String address) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _col(uid).doc(_addressId(address)).get();
    return doc.exists;
  }

  static Future<bool> toggle(String address) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final ref = _col(uid).doc(_addressId(address));
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
      return false;
    } else {
      await ref.set({
        'address': address,
        'followedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  static Future<List<String>> fetchFollowedAddresses(String uid) async {
    final snap = await _col(uid)
        .orderBy('followedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => d.data()['address'] as String? ?? '')
        .where((a) => a.isNotEmpty)
        .toList();
  }
}
