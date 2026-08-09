import 'package:flutter/material.dart';
import '../models/review.dart';

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
              // Address + rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      review.address,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StarChip(rating: overall),
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
              Wrap(
                spacing: 6,
                children: [
                  if (review.hadFormalContract) _Badge(label: 'Contrato formal', color: Colors.green),
                  if (review.avalRequired) _Badge(label: 'Requirió aval', color: Colors.orange),
                  if (!review.depositReturned) _Badge(label: 'Depósito no devuelto', color: Colors.red),
                  if (review.utilitiesIncluded) _Badge(label: 'Servicios incluidos', color: Colors.blue),
                ],
              ),

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
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 10, color: color)),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      side: BorderSide(color: color.withAlpha(100)),
      backgroundColor: color.withAlpha(20),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
