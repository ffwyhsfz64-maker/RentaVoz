import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import 'review_detail_screen.dart';

class AddressReviewsScreen extends StatefulWidget {
  const AddressReviewsScreen({
    super.key,
    required this.address,
    required this.lat,
    required this.lng,
    this.excludeId,
  });

  final String address;
  final double lat;
  final double lng;
  final String? excludeId;

  @override
  State<AddressReviewsScreen> createState() => _AddressReviewsScreenState();
}

class _AddressReviewsScreenState extends State<AddressReviewsScreen> {
  late Future<List<Review>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReviewService.fetchSameLocation(
      address: widget.address,
      lat: widget.lat,
      lng: widget.lng,
      excludeId: widget.excludeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(s.addressReviewsTitle)),
      body: FutureBuilder<List<Review>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snap.data ?? [];
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(s.addressReviewsNone, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 집계 통계 계산
          final count = reviews.length;
          final avgOverall = reviews.map((r) => r.overallRating).reduce((a, b) => a + b) / count;
          final avgLandlord = reviews.map((r) => r.landlordRating).reduce((a, b) => a + b) / count;
          final avgCondition = reviews.map((r) => r.conditionRating).reduce((a, b) => a + b) / count;
          final avgLocation = reviews.map((r) => r.locationRating).reduce((a, b) => a + b) / count;
          final avgSecurity = reviews.map((r) => r.securityRating).reduce((a, b) => a + b) / count;

          return CustomScrollView(
            slivers: [
              // 주소 + 통계 헤더
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.address,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // 전체 평점
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                avgOverall.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              Text(
                                s.addressReviewsCount(count),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          // 항목별 평점 바
                          Expanded(
                            child: Column(
                              children: [
                                _AvgBar(label: s.landlordRating, value: avgLandlord),
                                _AvgBar(label: s.conditionRating, value: avgCondition),
                                _AvgBar(label: s.locationRating, value: avgLocation),
                                _AvgBar(label: s.securityRating, value: avgSecurity),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 리뷰 목록
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ReviewCard(
                    review: reviews[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: reviews[i])),
                    ),
                  ),
                  childCount: count,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}

class _AvgBar extends StatelessWidget {
  const _AvgBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 5,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
