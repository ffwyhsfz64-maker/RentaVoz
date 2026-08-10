import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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

  // 같은 주소 문자열 + 100m 반경 리뷰를 합쳐서 반환 (excludeId 제외)
  static Future<List<Review>> fetchSameLocation({
    required String address,
    required double lat,
    required double lng,
    String? excludeId,
  }) async {
    const delta = 0.001; // ~111m

    final results = await Future.wait([
      // 1) 주소 문자열 일치
      _col.where('address', isEqualTo: address).get(),
      // 2) 위도 범위 (Firestore 단일 range 쿼리), 경도는 클라이언트 필터
      _col
          .where('lat', isGreaterThanOrEqualTo: lat - delta)
          .where('lat', isLessThanOrEqualTo: lat + delta)
          .get(),
    ]);

    final seen = <String>{};
    final reviews = <Review>[];
    for (final snap in results) {
      for (final doc in snap.docs) {
        final r = Review.fromMap(doc.id, doc.data());
        if (r.id == excludeId) continue;
        if ((r.lng - lng).abs() > delta) continue; // 경도 필터
        if (seen.add(r.id)) reviews.add(r);
      }
    }
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  static Future<List<Review>> fetchAll({String? rentalType}) async {
    Query<Map<String, dynamic>> q = rentalType != null
        ? _col.where('rentalType', isEqualTo: rentalType)
        : _col;
    final snap = await q.get();
    return snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
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

  static Future<void> addReview(Review review) async {
    await _col.doc(review.id).set(review.toMap());
    await FirebaseAnalytics.instance.logEvent(
      name: 'review_published',
      parameters: {
        'rental_type': review.rentalType,
        'overall_rating': review.overallRating,
        'is_verified': review.isVerified ? 1 : 0,
      },
    );
  }

  static Future<void> deleteReview(String reviewId) =>
      _col.doc(reviewId).delete();
}
