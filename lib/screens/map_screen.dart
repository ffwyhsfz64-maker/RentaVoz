import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Review? _lastSelected; // 애니메이션 아웃 중에도 카드 유지
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
      final all = reviews;
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
              onTap: () => setState(() { _selected = r; _lastSelected = r; }),
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

          // 범례 — 가로 pill 형태
          Positioned(
            top: 12,
            left: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: Colors.white.withAlpha(230),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendDot(color: Colors.green, label: s.legendGood.split(' ').last),
                    const SizedBox(width: 10),
                    _LegendDot(color: Colors.amber, label: s.legendRegular.split(' ').last),
                    const SizedBox(width: 10),
                    _LegendDot(color: Colors.red, label: s.legendBad.split(' ').last),
                  ],
                ),
              ),
            ),
          ),

          // 리뷰 수 badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.rate_review_rounded, size: 13, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    s.reviewCount(_totalCount),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // +/- 줌 버튼 — 세련된 카드 스타일
          Positioned(
            left: 12,
            bottom: _selected != null ? 200 : 100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  _ZoomButton(icon: Icons.add_rounded, heroTag: 'zoom_in', onTap: () => _zoom(1)),
                  Container(height: 1, color: Colors.grey[200]),
                  _ZoomButton(icon: Icons.remove_rounded, heroTag: 'zoom_out', onTap: () => _zoom(-1)),
                ],
              ),
            ),
          ),

          // 선택된 리뷰 카드 — 슬라이드업
          if (_lastSelected != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              bottom: _selected != null ? 0 : -300,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ReviewCard(
                        review: _lastSelected!,
                        onTap: () {
                          if (_selected == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewDetailScreen(review: _lastSelected!),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: -14,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = null),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                            ),
                            child: const Icon(Icons.close_rounded, size: 16, color: Colors.black54),
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.heroTag, required this.onTap});
  final IconData icon;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}
