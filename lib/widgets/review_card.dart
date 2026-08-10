import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/review.dart';
import '../screens/address_reviews_screen.dart';
import 'bookmark_button.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.onTap});

  final Review review;
  final VoidCallback? onTap;

  // Deterministic gradient based on address string
  List<Color> _gradientColors() {
    final h = review.address.codeUnits.fold(0, (a, b) => a + b) % 4;
    const sets = [
      [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      [Color(0xFF004D40), Color(0xFF00796B)],
      [Color(0xFF1A237E), Color(0xFF283593)],
      [Color(0xFF4A148C), Color(0xFF6A1B9A)],
    ];
    return sets[h];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overall = review.overallRating;
    final hasPhoto = review.photoUrls.isNotEmpty;
    final colors = _gradientColors();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top image / gradient placeholder ───────────────────
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhoto)
                    CachedNetworkImage(
                      imageUrl: review.photoUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _GradientPlaceholder(colors: colors, address: review.address),
                      errorWidget: (_, __, ___) => _GradientPlaceholder(colors: colors, address: review.address),
                    )
                  else
                    _GradientPlaceholder(colors: colors, address: review.address),

                  // Bottom shadow for text legibility
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Rating pill — top right
                  Positioned(
                    top: 12, right: 12,
                    child: _StarChip(rating: overall),
                  ),

                  // Bookmark — top left (logged-in only)
                  if (FirebaseAuth.instance.currentUser != null)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: BookmarkButton(reviewId: review.id, size: 22),
                      ),
                    ),

                  // Rental type badge — bottom left
                  Positioned(
                    bottom: 10, left: 12,
                    child: Builder(builder: (ctx) {
                      final s = S.of(ctx)!;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: review.rentalType == 'room'
                              ? Colors.purple.withAlpha(200)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: Text(
                          review.rentalType == 'room' ? '🚪 ${s.filterRoom}' : '🏠 ${s.filterHouse}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address — tappable
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddressReviewsScreen(
                          address: review.address,
                          lat: review.lat,
                          lng: review.lng,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 15, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            review.address,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF2E7D32),
                              decorationThickness: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Pros snippet
                  if (review.pros.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.thumb_up_outlined, size: 13, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            review.pros,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (review.pros.isNotEmpty) const SizedBox(height: 8),

                  // Badges
                  Builder(builder: (ctx) {
                    final s = S.of(ctx)!;
                    return Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (review.isVerified) _Badge(label: '✓ ${s.badgeVerified.replaceAll('✓ ', '')}', color: const Color(0xFF2E7D32), bold: true),
                        if (review.hadFormalContract) _Badge(label: s.badgeFormalContract, color: Colors.green),
                        if (review.avalRequired) _Badge(label: s.badgeAvalRequired, color: Colors.orange),
                        if (!review.depositReturned) _Badge(label: s.badgeDepositNotReturned, color: Colors.red),
                        if (review.utilitiesIncluded) _Badge(label: s.badgeUtilitiesIncluded, color: Colors.blue),
                        if (review.rentalType == 'room' && review.sharedBathroom) _Badge(label: s.sharedBathroom, color: Colors.teal),
                        if (review.rentalType == 'room' && review.sharedKitchen) _Badge(label: s.sharedKitchen, color: Colors.teal),
                      ],
                    );
                  }),

                  const SizedBox(height: 10),

                  // Rent + date footer
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${review.monthlyRent.toStringAsFixed(0)} MXN/mes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDateRange(review.moveInDate, review.moveOutDate),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime from, DateTime to) {
    String fmt(DateTime d) => '${d.month}/${d.year}';
    return '${fmt(from)} – ${fmt(to)}';
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({required this.colors, required this.address});
  final List<Color> colors;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(Icons.home_outlined, size: 56, color: Colors.white24),
      ),
    );
  }
}

class _StarChip extends StatelessWidget {
  const _StarChip({required this.rating});
  final double rating;

  Color get _color {
    if (rating >= 4) return const Color(0xFF2E7D32);
    if (rating >= 3) return const Color(0xFFF57C00);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.bold = false});
  final String label;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: bold ? FontWeight.bold : FontWeight.w500),
      ),
    );
  }
}
