import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  static final _col = FirebaseFirestore.instance.collection('reviews');

  static Stream<List<Review>> feedStream() => _col
      .orderBy('createdAt', descending: true)
      .limit(50)
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
