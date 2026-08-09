import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class AddressResult {
  final String address;
  final double lat;
  final double lng;

  const AddressResult({required this.address, required this.lat, required this.lng});
}

class AddressField extends StatefulWidget {
  const AddressField({
    super.key,
    required this.onSelected,
    this.initialValue = '',
  });

  final ValueChanged<AddressResult> onSelected;
  final String initialValue;

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  List<_Prediction> _predictions = [];
  Timer? _debounce;
  bool _loadingLocation = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initialValue;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.length < 3) {
      setState(() { _predictions = []; _showSuggestions = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _fetchPredictions(value));
  }

  static const _headers = {'x-ios-bundle-identifier': 'com.onuri.rentavoz'};

  Future<void> _fetchPredictions(String input) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&components=country:mx'
      '&language=es'
      '&key=$kGoogleApiKey',
    );
    try {
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'OK') {
          setState(() {
            _predictions = (data['predictions'] as List)
                .map((p) => _Prediction(
                      placeId: p['place_id'] as String,
                      description: p['description'] as String,
                    ))
                .toList();
            _showSuggestions = true;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _selectPrediction(_Prediction prediction) async {
    setState(() { _showSuggestions = false; _predictions = []; });
    _ctrl.text = prediction.description;
    _focusNode.unfocus();

    // Place Details로 좌표 가져오기
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=${prediction.placeId}'
      '&fields=geometry'
      '&key=$kGoogleApiKey',
    );
    try {
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final loc = data['result']['geometry']['location'];
        widget.onSelected(AddressResult(
          address: prediction.description,
          lat: (loc['lat'] as num).toDouble(),
          lng: (loc['lng'] as num).toDouble(),
        ));
      }
    } catch (_) {
      widget.onSelected(AddressResult(address: prediction.description, lat: 0, lng: 0));
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activa los permisos de ubicación en Ajustes')),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if (p.street?.isNotEmpty == true) p.street,
          if (p.subLocality?.isNotEmpty == true) p.subLocality,
          if (p.locality?.isNotEmpty == true) p.locality,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea,
        ].join(', ');
        _ctrl.text = address;
        widget.onSelected(AddressResult(address: address, lat: pos.latitude, lng: pos.longitude));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicación')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Ej. Calle Morelos 123, Col. Centro, Querétaro',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: const OutlineInputBorder(),
            suffixIcon: _loadingLocation
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Usar mi ubicación actual',
                    onPressed: _useCurrentLocation,
                  ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la dirección' : null,
        ),

        // Autocomplete suggestions
        if (_showSuggestions && _predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withAlpha(80)),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8)],
            ),
            child: Column(
              children: _predictions.map((p) => InkWell(
                onTap: () => _selectPrediction(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(p.description, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

class _Prediction {
  final String placeId;
  final String description;
  const _Prediction({required this.placeId, required this.description});
}
