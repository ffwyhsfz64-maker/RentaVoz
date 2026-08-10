import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/dummy_reviews.dart';
import '../l10n/app_localizations.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import 'review_detail_screen.dart';

const _queretaro = LatLng(20.5888, -100.3899);
const _clusterManagerId = ClusterManagerId('reviews');

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
  int _totalCount = 0;

  late final Set<ClusterManager> _clusterManagers = {
    ClusterManager(
      clusterManagerId: _clusterManagerId,
      onClusterTap: (Cluster cluster) async {
        final ctrl = await _mapCtrl.future;
        if (cluster.bounds != null) {
          ctrl.animateCamera(
            CameraUpdate.newLatLngBounds(cluster.bounds!, 60),
          );
        } else {
          final zoom = await ctrl.getZoomLevel();
          ctrl.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.position, zoom + 2),
          );
        }
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    _sub = ReviewService.feedStream().listen((reviews) {
      final all = reviews.isEmpty ? dummyReviews : reviews;
      if (!mounted) return;
      setState(() {
        _totalCount = all.where((r) => r.lat != 0 && r.lng != 0).length;
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
              clusterManagerId: _clusterManagerId,
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

  Future<void> _zoom(double delta) async {
    final ctrl = await _mapCtrl.future;
    final current = await ctrl.getZoomLevel();
    ctrl.animateCamera(CameraUpdate.newLatLngZoom(
      _queretaro,
      (current + delta).clamp(2.0, 21.0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.mapTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: s.centerMap,
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
            initialCameraPosition:
                const CameraPosition(target: _queretaro, zoom: 13),
            markers: _markers,
            clusterManagers: _clusterManagers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (ctrl) => _mapCtrl.complete(ctrl),
            onTap: (_) => setState(() => _selected = null),
          ),

          // 범례
          Positioned(
            top: 12,
            left: 12,
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(color: Colors.green, label: s.legendGood),
                    _LegendItem(color: Colors.amber, label: s.legendRegular),
                    _LegendItem(color: Colors.red, label: s.legendBad),
                  ],
                ),
              ),
            ),
          ),

          // 리뷰 수
          Positioned(
            top: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  s.reviewCount(_totalCount),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ),

          // +/- 줌 버튼
          Positioned(
            right: 12,
            bottom: _selected != null ? 200 : 80,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () => _zoom(1),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () => _zoom(-1),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // 선택된 리뷰 카드
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
                            builder: (_) =>
                                ReviewDetailScreen(review: _selected!),
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
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
