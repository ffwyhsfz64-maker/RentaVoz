import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static final _col = FirebaseFirestore.instance.collection('reports');

  static Future<bool> hasReported(String reviewId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final snap = await _col
        .where('reviewId', isEqualTo: reviewId)
        .where('reporterId', isEqualTo: uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  static Future<void> submit(String reviewId, String reason) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docId = '${reviewId}_$uid';
    await _col.doc(docId).set({
      'reviewId': reviewId,
      'reporterId': uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
