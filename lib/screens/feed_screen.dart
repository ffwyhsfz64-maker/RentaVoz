import 'package:flutter/material.dart';
import '../data/dummy_reviews.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import 'review_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _search = '';

  List<Review> _filter(List<Review> reviews) {
    if (_search.isEmpty) return reviews;
    final q = _search.toLowerCase();
    return reviews.where((r) => r.address.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RentaVoz'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SearchBar(
              hintText: 'Buscar por dirección o colonia…',
              leading: const Icon(Icons.search, size: 20),
              onChanged: (v) => setState(() => _search = v),
              elevation: const WidgetStatePropertyAll(1),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Review>>(
        stream: ReviewService.feedStream(),
        builder: (context, snap) {
          // Firestore에 데이터가 없으면 더미 데이터를 보여줌
          final reviews = _filter(
            (snap.data?.isEmpty ?? true) ? dummyReviews : snap.data!,
          );

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    _search.isEmpty ? 'No hay reseñas aún' : 'Sin resultados para "$_search"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reviews.length,
            itemBuilder: (context, index) => ReviewCard(
              review: reviews[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: reviews[index])),
              ),
            ),
          );
        },
      ),
    );
  }
}
