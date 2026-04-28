import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../../utils/test_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';


class PlacesSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String googleApiKey;
  final Function(Map<String, dynamic> place) onPlaceSelected;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClearPressed;
  final bool showResultsOnly;

  /// 🔥 Optional: map center for better accuracy
  final LatLng? locationBias;

  const PlacesSearchWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.googleApiKey,
    required this.onPlaceSelected,
    this.onBackPressed,
    this.onClearPressed,
    this.showResultsOnly = false,
    this.locationBias,
  });

  @override
  State<PlacesSearchWidget> createState() => _PlacesSearchWidgetState();
}

class _PlacesSearchWidgetState extends State<PlacesSearchWidget> {
  final List<Map<String, dynamic>> _predictions = [];
  Timer? _debounce;
  String _sessionToken = '';
  bool _isLoading = false;

int _getDynamicRadius(String query) {
  if (query.length <= 3) return 5000;
  if (query.length <= 6) return 10000;
  return 20000;
}
  @override
  void initState() {
    super.initState();
    _sessionToken = _newSessionToken();
    widget.controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onQueryChanged);
    super.dispose();
  }

  String _newSessionToken() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  void _onQueryChanged() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = widget.controller.text.trim();
      if (query.length >= 2) {
        _fetchPredictions(query);
      } else {
        setState(() => _predictions.clear());
      }
    });
  }

  // ---------------------------------------------------------
  // 🔍 AUTOCOMPLETE (LOCATION-BIASED & PROFESSIONAL)
  // ---------------------------------------------------------
  Future<void> _fetchPredictions(String input) async {
    setState(() => _isLoading = true);

    try {
      final bias = widget.locationBias;
      final radius = _getDynamicRadius(input);

final locationParams = bias != null
    ? '&location=${bias.latitude},${bias.longitude}&radius=$radius'
    : '';

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=${widget.googleApiKey}'
        '&sessiontoken=$_sessionToken'
        '&components=country:in'
        ''
        '$locationParams'
        '&language=en',
      );

      final res = await http.get(uri);
      final body = json.decode(res.body);

     if (body['status'] != 'OK' || body['predictions'].isEmpty) {
  await _fetchNearbyPlaces(input);
  setState(() {
    _isLoading = false;
  });
  return;
}

      final List list = body['predictions'];

      setState(() {
  _predictions
    ..clear()
    ..addAll(list.map((p) => {
          'placeId': p['place_id'],
          'main': p['structured_formatting']['main_text'],
          'secondary':
              p['structured_formatting']['secondary_text'] ?? '',
          'types': p['types'] ?? [],
        }));
});

await _sortByDistance();

setState(() {
  _isLoading = false;
});
    } catch (_) {
      setState(() {
        _predictions.clear();
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------
  // 📍 PLACE DETAILS (FINAL SELECTION)
  // ---------------------------------------------------------
  Future<void> _selectPlace(String placeId) async {
    try {
      setState(() => _isLoading = true);

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=${widget.googleApiKey}'
        '&sessiontoken=$_sessionToken'
        '&fields=geometry,formatted_address,name,address_components',
      );

      final res = await http.get(uri);
      final body = json.decode(res.body);

      if (body['status'] != 'OK') {
        setState(() => _isLoading = false);
        return;
      }

      final result = body['result'];
      final loc = result['geometry']['location'];

      widget.onPlaceSelected({
        'lat': loc['lat'],
        'lng': loc['lng'],
        'address': result['formatted_address'],
        'name': result['name'],
        'components': result['address_components'],
      });

      // New session after selection (Google best practice)
      _sessionToken = _newSessionToken();

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------
  // 🏷️ CATEGORY TAG (SMART PRIORITY)
  // ---------------------------------------------------------
  String _categoryFromTypes(List types) {
    const priority = [
      'locality',
      'sublocality_level_1',
      'neighborhood',
      'route',
      'premise',
      'shopping_mall',
      'hospital',
      'school',
      'university',
      'restaurant',
      'establishment',
      'point_of_interest',
    ];

    const labels = {
      'locality': 'City',
      'sublocality_level_1': 'Area',
      'neighborhood': 'Neighborhood',
      'route': 'Street',
      'premise': 'Building',
      'shopping_mall': 'Mall',
      'hospital': 'Hospital',
      'school': 'School',
      'university': 'University',
      'restaurant': 'Restaurant',
      'establishment': 'Place',
      'point_of_interest': 'Landmark',
    };

    for (final key in priority) {
      if (types.contains(key)) return labels[key] ?? '';
    }
    return '';
  }

  // ---------------------------------------------------------
  // 🧱 UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!widget.showResultsOnly) return const SizedBox();

    return Column(
      children: [
        if (_isLoading)
          Padding(
            padding: EdgeInsets.all(16.h),
            child: const CircularProgressIndicator(
              color: Color(0xFFE47830),
              strokeWidth: 2,
            ),
          ).withId('places_search_loading'),

        if (!_isLoading && _predictions.isEmpty &&
            widget.controller.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(24.h),
            child: Text(
              'No nearby locations found',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ).withId('places_search_empty'),

        if (_predictions.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (_, i) {
                final p = _predictions[i];
                final category = _categoryFromTypes(p['types']);

                return InkWell(
                  onTap: () => _selectPlace(p['placeId']),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey[200]!, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE47830).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on,
                              color: Color(0xFFE47830), size: 20),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['main'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (p['secondary'].isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  p['secondary'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              if (category.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF8C42)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFF8C42),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ).withId('place_prediction_$i');
              },
            ),
          ),
      ],
    );
  }
  double _distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371000;

  final dLat = (lat2 - lat1) * (pi / 180);
  final dLng = (lng2 - lng1) * (pi / 180);

  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180)) *
          cos(lat2 * (pi / 180)) *
          sin(dLng / 2) *
          sin(dLng / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}
Future<LatLng?> _getLatLng(String placeId) async {
  final uri = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/details/json'
    '?place_id=$placeId'
    '&key=${widget.googleApiKey}'
    '&fields=geometry',
  );

  final res = await http.get(uri);
  final body = json.decode(res.body);

  if (body['status'] != 'OK') return null;

  final loc = body['result']['geometry']['location'];
  return LatLng(loc['lat'], loc['lng']);
}
Future<void> _sortByDistance() async {
  if (widget.locationBias == null) return;

  final origin = widget.locationBias!;

  for (var p in _predictions.take(5)) {
    final latLng = await _getLatLng(p['placeId']);
    if (latLng != null) {
      p['distance'] = _distanceMeters(
        origin.latitude,
        origin.longitude,
        latLng.latitude,
        latLng.longitude,
      );
    }
  }

  _predictions.sort((a, b) =>
      (a['distance'] ?? 999999).compareTo(b['distance'] ?? 999999));
}
Future<void> _fetchNearbyPlaces(String input) async {
  final bias = widget.locationBias;
  if (bias == null) return;

  final uri = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=${bias.latitude},${bias.longitude}'
    '&radius=5000'
    '&keyword=${Uri.encodeComponent(input)}'
    '&key=${widget.googleApiKey}',
  );

  final res = await http.get(uri);
  final body = json.decode(res.body);

  if (body['status'] != 'OK') return;

  final results = body['results'];

  setState(() {
    _predictions
      ..clear()
      ..addAll(results.map((r) => {
            'placeId': r['place_id'],
            'main': r['name'],
            'secondary': r['vicinity'] ?? '',
            'types': r['types'] ?? [],
          }));
  });
}
}
