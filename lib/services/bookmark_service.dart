import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class BookmarkService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('bookmarks');

  static Future<bool> isBookmarked(String uid, String reviewId) async {
    final doc = await _col(uid).doc(reviewId).get();
    return doc.exists;
  }

  static Future<bool> toggle(String uid, String reviewId) async {
    final doc = _col(uid).doc(reviewId);
    final snap = await doc.get();
    if (snap.exists) {
      await doc.delete();
      return false;
    } else {
      await doc.set({'savedAt': FieldValue.serverTimestamp()});
      return true;
    }
  }

  static Stream<Set<String>> bookmarkedIdsStream(String uid) => _col(uid)
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());

  static Future<List<Review>> fetchBookmarkedReviews(String uid) async {
    final snap = await _col(uid).orderBy('savedAt', descending: true).get();
    if (snap.docs.isEmpty) return [];
    final ids = snap.docs.map((d) => d.id).toList();
    final reviews = <Review>[];
    for (var i = 0; i < ids.length; i += 10) {
      final batch = ids.sublist(i, (i + 10).clamp(0, ids.length));
      final result = await _firestore
          .collection('reviews')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      reviews.addAll(result.docs.map((d) => Review.fromMap(d.id, d.data())));
    }
    final order = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    reviews.sort((a, b) => (order[a.id] ?? 0).compareTo(order[b.id] ?? 0));
    return reviews;
  }
}
