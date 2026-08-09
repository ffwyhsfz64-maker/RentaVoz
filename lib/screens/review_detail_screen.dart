import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewDetailScreen extends StatelessWidget {
  const ReviewDetailScreen({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de reseña'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall score hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('de 5.0', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _RatingBar(label: 'Arrendador', value: review.landlordRating),
                      _RatingBar(label: 'Inmueble', value: review.conditionRating),
                      _RatingBar(label: 'Ubicación', value: review.locationRating),
                      _RatingBar(label: 'Seguridad', value: review.securityRating),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Address
          _Section(
            title: 'Dirección',
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Expanded(child: Text(review.address)),
              ],
            ),
          ),

          // Período y renta
          _Section(
            title: 'Período y renta',
            child: Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Entrada',
                    value: _fmtDate(review.moveInDate),
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_month,
                    label: 'Salida',
                    value: _fmtDate(review.moveOutDate),
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.attach_money,
                    label: 'Renta',
                    value: '\$${review.monthlyRent.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
          ),

          // Contrato
          _Section(
            title: 'Detalles del contrato',
            child: Column(
              children: [
                _BoolRow(label: 'Contrato formal', value: review.hadFormalContract),
                _BoolRow(label: 'Requirió aval', value: review.avalRequired, invertColor: true),
                _BoolRow(label: 'Depósito devuelto', value: review.depositReturned),
                _BoolRow(label: 'Servicios incluidos', value: review.utilitiesIncluded),
              ],
            ),
          ),

          // Pros
          if (review.pros.isNotEmpty)
            _Section(
              title: '¿Qué gustó?',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.thumb_up_outlined, size: 18, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(review.pros, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),

          // Cons
          if (review.cons.isNotEmpty)
            _Section(
              title: '¿Qué no gustó?',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.thumb_down_outlined, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(review.cons, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),

          const SizedBox(height: 16),
          Text(
            'Publicada el ${_fmtDateFull(review.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtDateFull(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
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
          Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BoolRow extends StatelessWidget {
  const _BoolRow({required this.label, required this.value, this.invertColor = false});
  final String label;
  final bool value;
  final bool invertColor;

  @override
  Widget build(BuildContext context) {
    final positive = invertColor ? !value : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            positive ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 18,
            color: positive ? const Color(0xFF2E7D32) : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
