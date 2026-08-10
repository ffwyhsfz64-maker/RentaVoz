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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overall = review.overallRating;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address + rating + bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
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
                      child: Text(
                        review.address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF2E7D32),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StarChip(rating: overall),
                  if (FirebaseAuth.instance.currentUser != null) ...[
                    const SizedBox(width: 4),
                    BookmarkButton(reviewId: review.id, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // Rating breakdown
              Row(
                children: [
                  _MiniRating(label: 'Propietario', value: review.landlordRating),
                  const SizedBox(width: 12),
                  _MiniRating(label: 'Inmueble', value: review.conditionRating),
                  const SizedBox(width: 12),
                  _MiniRating(label: 'Seguridad', value: review.securityRating),
                ],
              ),
              const SizedBox(height: 10),

              // Pros snippet
              if (review.pros.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.thumb_up_outlined, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        review.pros,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Badges
              Builder(builder: (context) {
                final s = S.of(context)!;
                return Wrap(
                  spacing: 6,
                  children: [
                    if (review.rentalType == 'room')
                      _Badge(label: '🚪 ${s.badgeRoom}', color: Colors.purple),
                    if (review.isVerified) _Badge(label: '✓ ${s.badgeVerified.replaceAll('✓ ', '')}', color: const Color(0xFF2E7D32), bold: true),
                    if (review.hadFormalContract) _Badge(label: s.badgeFormalContract, color: Colors.green),
                    if (review.avalRequired) _Badge(label: s.badgeAvalRequired, color: Colors.orange),
                    if (!review.depositReturned) _Badge(label: s.badgeDepositNotReturned, color: Colors.red),
                    if (review.utilitiesIncluded) _Badge(label: s.badgeUtilitiesIncluded, color: Colors.blue),
                    if (review.rentalType == 'room' && review.sharedBathroom)
                      _Badge(label: s.sharedBathroom, color: Colors.teal),
                    if (review.rentalType == 'room' && review.sharedKitchen)
                      _Badge(label: s.sharedKitchen, color: Colors.teal),
                  ],
                );
              }),

              const SizedBox(height: 8),

              // Rent + date
              Row(
                children: [
                  Text(
                    '\$${review.monthlyRent.toStringAsFixed(0)} MXN/mes',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  String _formatDateRange(DateTime from, DateTime to) {
    String fmt(DateTime d) => '${d.month}/${d.year}';
    return '${fmt(from)} – ${fmt(to)}';
  }
}

class _StarChip extends StatelessWidget {
  const _StarChip({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.white),
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

class _MiniRating extends StatelessWidget {
  const _MiniRating({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Row(
          children: List.generate(5, (i) => Icon(
            i < value ? Icons.star : Icons.star_border,
            size: 12,
            color: const Color(0xFF2E7D32),
          )),
        ),
      ],
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
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      side: BorderSide(color: color.withAlpha(100)),
      backgroundColor: color.withAlpha(20),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
