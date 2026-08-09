import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import 'review_detail_screen.dart';
import 'write_review_screen.dart';
import 'auth/login_screen.dart';
import 'settings_screen.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  void _showActions(BuildContext context, Review review) {
    final s = S.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(s.editReview),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WriteReviewScreen(existingReview: review)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(s.deleteReview, style: const TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(s.deleteConfirmTitle),
                    content: Text(s.deleteConfirmBody),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ReviewService.deleteReview(review.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.reviewDeleted)),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final uid = AuthService.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.tabMyReviews)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(s.loginNeedAccount),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: Text(s.loginToSeeReviews),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.tabMyReviews),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: s.settingsTitle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: s.logout,
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Review>>(
        stream: ReviewService.userReviewsStream(uid),
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
                  const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(s.myReviewsEmpty, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(s.myReviewsEmptyHint, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reviews.length,
            itemBuilder: (context, i) => Dismissible(
              key: Key(reviews[i].id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.red,
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(s.deleteConfirmTitle),
                    content: Text(s.deleteConfirmBody),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
                    ],
                  ),
                );
              },
              onDismissed: (_) async {
                await ReviewService.deleteReview(reviews[i].id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.reviewDeleted)),
                  );
                }
              },
              child: GestureDetector(
                onLongPress: () => _showActions(context, reviews[i]),
                child: ReviewCard(
                  review: reviews[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: reviews[i])),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
