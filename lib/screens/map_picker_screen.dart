import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../widgets/address_field.dart';

const _queretaro = LatLng(20.5888, -100.3899);

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initialPosition});

  final LatLng? initialPosition;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final Completer<GoogleMapController> _mapCtrl = Completer();
  LatLng _center = _queretaro;
  String _address = '';
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _center = widget.initialPosition!;
    }
    _reverseGeocode(_center);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onCameraMove(CameraPosition pos) {
    _center = pos.target;
    _debounce?.cancel();
  }

  void _onCameraIdle() {
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _reverseGeocode(_center),
    );
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _address = '';
    });
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${pos.latitude},${pos.longitude}'
        '&language=es'
        '&key=$kGoogleApiKey',
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final addr = results[0]['formatted_address'] as String;
          if (mounted) setState(() => _address = addr);
        } else {
          // API key invalid or no results — show coordinates as fallback
          if (mounted) {
            setState(() => _address =
                '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
          }
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _address =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToMyLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Activa los permisos de ubicación en Ajustes')),
        );
      }
      return;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final ctrl = await _mapCtrl.future;
    ctrl.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(pos.latitude, pos.longitude), 17),
    );
  }

  void _confirm() {
    if (_address.isEmpty) return;
    Navigator.pop(
      context,
      AddressResult(
        address: _address,
        lat: _center.latitude,
        lng: _center.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _address.isNotEmpty && !_loading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar en el mapa'),
        actions: [
          TextButton(
            onPressed: canConfirm ? _confirm : null,
            child: const Text('Confirmar'),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 16),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (ctrl) => _mapCtrl.complete(ctrl),
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
          ),

          // 중앙 핀 (지도 이동 시 고정)
          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_pin,
                    size: 52,
                    color: Color(0xFF2E7D32),
                  ),
                  // 핀 그림자 효과
                  Container(
                    width: 10,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 내 위치 버튼
          Positioned(
            right: 12,
            bottom: 140,
            child: FloatingActionButton.small(
              heroTag: 'map_picker_my_location',
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // 하단 주소 카드
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _loading
                              ? const SizedBox(
                                  height: 14,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Color(0xFFE8F5E9),
                                    color: Color(0xFF2E7D32),
                                  ),
                                )
                              : Text(
                                  _address.isNotEmpty
                                      ? _address
                                      : 'Mueve el mapa para seleccionar',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: canConfirm ? _confirm : null,
                        child: const Text('Confirmar esta ubicación'),
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
