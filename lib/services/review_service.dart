import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

typedef FeedPage = ({List<Review> reviews, DocumentSnapshot? lastDoc});

class ReviewService {
  static final _col = FirebaseFirestore.instance.collection('reviews');

  static Future<FeedPage> fetchPage({
    String? rentalType,
    String orderField = 'createdAt',
    bool descending = true,
    DocumentSnapshot? after,
    int limit = 15,
  }) async {
    Query<Map<String, dynamic>> q;
    if (rentalType != null) {
      q = _col
          .where('rentalType', isEqualTo: rentalType)
          .orderBy(orderField, descending: descending)
          .limit(limit);
    } else {
      q = _col.orderBy(orderField, descending: descending).limit(limit);
    }
    if (after != null) q = q.startAfterDocument(after);
    final snap = await q.get();
    final reviews = snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
    return (reviews: reviews, lastDoc: snap.docs.isEmpty ? null : snap.docs.last);
  }

  static Stream<List<Review>> feedStream() => _col
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => Review.fromMap(d.id, d.data())).toList());

  static Stream<List<Review>> userReviewsStream(String userId) => _col
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) {
        final reviews = s.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return reviews;
      });

  static Future<void> addReview(Review review) =>
      _col.doc(review.id).set(review.toMap());

  static Future<void> deleteReview(String reviewId) =>
      _col.doc(reviewId).delete();
}
