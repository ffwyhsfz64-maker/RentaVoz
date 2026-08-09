import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/dummy_reviews.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import 'review_detail_screen.dart';

const _queretaro = LatLng(20.5888, -100.3899);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapCtrl = Completer();
  Set<Marker> _markers = {};
  Review? _selected;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ReviewService.feedStream().listen((reviews) {
      final all = reviews.isEmpty ? dummyReviews : reviews;
      setState(() {
        _markers = _buildMarkers(all);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<Review> reviews) {
    return reviews
        .where((r) => r.lat != 0 && r.lng != 0)
        .map((r) => Marker(
              markerId: MarkerId(r.id),
              position: LatLng(r.lat, r.lng),
              infoWindow: InfoWindow(title: r.address),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                r.overallRating >= 4
                    ? BitmapDescriptor.hueGreen
                    : r.overallRating >= 3
                        ? BitmapDescriptor.hueYellow
                        : BitmapDescriptor.hueRed,
              ),
              onTap: () => setState(() => _selected = r),
            ))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de reseñas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centrar en Querétaro',
            onPressed: () async {
              final ctrl = await _mapCtrl.future;
              ctrl.animateCamera(CameraUpdate.newLatLngZoom(_queretaro, 13));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: _queretaro, zoom: 13),
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (ctrl) => _mapCtrl.complete(ctrl),
            onTap: (_) => setState(() => _selected = null),
          ),

          // Leyenda
          Positioned(
            top: 12,
            left: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(color: Colors.green, label: '★ 4–5  Bueno'),
                    _LegendItem(color: Colors.amber, label: '★ 3–4  Regular'),
                    _LegendItem(color: Colors.red, label: '★ 1–3  Malo'),
                  ],
                ),
              ),
            ),
          ),

          // Contador
          Positioned(
            top: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '${_markers.length} reseñas',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ),

          // Bottom sheet al seleccionar un pin
          if (_selected != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Cerrar
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const CircleAvatar(
                            radius: 14,
                            child: Icon(Icons.close, size: 16),
                          ),
                          onPressed: () => setState(() => _selected = null),
                        ),
                      ),
                      ReviewCard(
                        review: _selected!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewDetailScreen(review: _selected!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
