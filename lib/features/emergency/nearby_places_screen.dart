import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum _PlaceType { hospital, clinic, police, safeSpace }

class _NearbyPlace {
  const _NearbyPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.point,
  });

  final String id;
  final String name;
  final _PlaceType type;
  final LatLng point;
}

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  static const _radiusMeters = 10000;
  static const _tileUserAgent = 'com.example.silenthelp';

  final MapController _mapController = MapController();
  LatLng? _userLocation;
  List<_NearbyPlace> _places = const [];
  _NearbyPlace? _selectedPlace;
  _PlaceType? _selectedType;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearbyPlaces());
  }

  Future<void> _loadNearbyPlaces() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var location = await LocationService.getCachedLocation();
      if (location == null) {
        final hasPermission = await LocationService.ensureLocationPermission();
        if (!hasPermission) {
          throw Exception(
            'Location permission is needed to find nearby places.',
          );
        }
        location = await LocationService.getFullLocation();
      }

      if (location == null) {
        throw Exception(
          'Could not get your location. Check GPS and try again.',
        );
      }

      final center = LatLng(location.latitude, location.longitude);
      if (mounted) setState(() => _userLocation = center);
      final places = await _fetchPlaces(center);
      if (mounted) {
        setState(() {
          _places = places;
          _errorMessage = places.isEmpty
              ? 'No mapped places found within 10 km.'
              : null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () =>
              _errorMessage = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<_NearbyPlace>> _fetchPlaces(LatLng center) async {
    final query =
        '''
[out:json][timeout:20];
(
  node(around:$_radiusMeters,${center.latitude},${center.longitude})["amenity"~"^(hospital|clinic|police)\$"];
  way(around:$_radiusMeters,${center.latitude},${center.longitude})["amenity"~"^(hospital|clinic|police)\$"];
  relation(around:$_radiusMeters,${center.latitude},${center.longitude})["amenity"~"^(hospital|clinic|police)\$"];
  node(around:$_radiusMeters,${center.latitude},${center.longitude})["healthcare"~"^(hospital|clinic|doctor)\$"];
  way(around:$_radiusMeters,${center.latitude},${center.longitude})["healthcare"~"^(hospital|clinic|doctor)\$"];
  relation(around:$_radiusMeters,${center.latitude},${center.longitude})["healthcare"~"^(hospital|clinic|doctor)\$"];
  node(around:$_radiusMeters,${center.latitude},${center.longitude})["amenity"="social_facility"]["social_facility"="shelter"]["social_facility:for"~"women|abused|victim",i];
  way(around:$_radiusMeters,${center.latitude},${center.longitude})["amenity"="social_facility"]["social_facility"="shelter"]["social_facility:for"~"women|abused|victim",i];
  relation(around:$_radiusMeters,${center.latitude},${center.longitude})["amenity"="social_facility"]["social_facility"="shelter"]["social_facility:for"~"women|abused|victim",i];
);
out center tags;
''';
    final response = await http
        .post(
          Uri.https('overpass-api.de', '/api/interpreter'),
          headers: const {'content-type': 'application/x-www-form-urlencoded'},
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw Exception('Nearby place search is unavailable. Please try again.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = payload['elements'] as List<dynamic>? ?? const [];
    final placesById = <String, _NearbyPlace>{};
    for (final rawElement in elements) {
      final element = rawElement as Map<String, dynamic>;
      final tags = element['tags'] as Map<String, dynamic>? ?? const {};
      final type = _placeType(tags);
      if (type == null) continue;

      final centerData = element['center'] as Map<String, dynamic>?;
      final latitude = (element['lat'] as num?) ?? (centerData?['lat'] as num?);
      final longitude =
          (element['lon'] as num?) ?? (centerData?['lon'] as num?);
      if (latitude == null || longitude == null) continue;

      final id = '${element['type']}:${element['id']}';
      final name = (tags['name'] as String?)?.trim();
      placesById[id] = _NearbyPlace(
        id: id,
        name: name == null || name.isEmpty ? _typeLabel(type) : name,
        type: type,
        point: LatLng(latitude.toDouble(), longitude.toDouble()),
      );
    }

    return placesById.values.toList()..sort(
      (first, second) => const Distance()
          .as(LengthUnit.Meter, center, first.point)
          .compareTo(
            const Distance().as(LengthUnit.Meter, center, second.point),
          ),
    );
  }

  _PlaceType? _placeType(Map<String, dynamic> tags) {
    final amenity = tags['amenity'];
    final healthcare = tags['healthcare'];
    if (amenity == 'police') {
      return _PlaceType.police;
    }
    if (amenity == 'hospital' || healthcare == 'hospital') {
      return _PlaceType.hospital;
    }
    if (amenity == 'clinic' ||
        healthcare == 'clinic' ||
        healthcare == 'doctor') {
      return _PlaceType.clinic;
    }
    if (amenity == 'social_facility' && tags['social_facility'] == 'shelter') {
      return _PlaceType.safeSpace;
    }
    return null;
  }

  List<_NearbyPlace> get _visiblePlaces => _selectedType == null
      ? _places
      : _places.where((place) => place.type == _selectedType).toList();

  String _typeLabel(_PlaceType type) => switch (type) {
    _PlaceType.hospital => 'Hospital',
    _PlaceType.clinic => 'Clinic / health centre',
    _PlaceType.police => 'Police station',
    _PlaceType.safeSpace => 'Women’s shelter',
  };

  Color _typeColor(_PlaceType type) => switch (type) {
    _PlaceType.hospital => AppColors.red,
    _PlaceType.clinic => AppColors.blue,
    _PlaceType.police => AppColors.yellow,
    _PlaceType.safeSpace => AppColors.purple,
  };

  IconData _typeIcon(_PlaceType type) => switch (type) {
    _PlaceType.hospital => Icons.local_hospital,
    _PlaceType.clinic => Icons.medical_services,
    _PlaceType.police => Icons.local_police,
    _PlaceType.safeSpace => Icons.shield_outlined,
  };

  void _selectPlace(_NearbyPlace place) {
    setState(() => _selectedPlace = place);
    _mapController.move(place.point, 16);
  }

  Future<void> _openGoogleMapsFallback() async {
    final searchTerm = switch (_selectedType) {
      _PlaceType.hospital => 'hospitals',
      _PlaceType.clinic => 'clinics and health centres',
      _PlaceType.police => 'police stations',
      _PlaceType.safeSpace => "women's shelters and support services",
      null => 'hospitals, clinics, police stations, and women’s shelters',
    };
    final location = _userLocation;
    final query = location == null
        ? '$searchTerm near me'
        : '$searchTerm near ${location.latitude},${location.longitude}';
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Nearby Support', style: AppTextStyles.heading2),
        actions: [
          IconButton(
            tooltip: 'Refresh nearby places',
            onPressed: _isLoading ? null : _loadNearbyPlaces,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'Places within 10 km are shown on this map. Your coordinates are sent '
            'to OpenStreetMap services to load map tiles and nearby listings.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: 12.h),
          if (_places.any((place) => place.type == _PlaceType.safeSpace))
            Container(
              padding: EdgeInsets.all(10.w),
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.purple),
              ),
              child: Text(
                'Shelter results come from public map data and are not verified '
                'by SilentHelp. Confirm a place is safe and open before travelling.',
                style: AppTextStyles.caption,
              ),
            ),
          SizedBox(
            height: 46.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('All', null),
                _filterChip('Hospitals', _PlaceType.hospital),
                _filterChip('Clinics', _PlaceType.clinic),
                _filterChip('Police', _PlaceType.police),
                _filterChip('Safe spaces', _PlaceType.safeSpace),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          if (_userLocation == null)
            Container(
              height: 340.h,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_off_outlined, size: 40),
                          SizedBox(height: 8.h),
                          Text(
                            _errorMessage ??
                                'Location is needed to show the map.',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _loadNearbyPlaces,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
              ),
            )
          else
            SizedBox(
              height: 380.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation!,
                    initialZoom: 14,
                    minZoom: 4,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: _tileUserAgent,
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLocation!,
                          width: 42,
                          height: 42,
                          child: Icon(
                            Icons.my_location,
                            color: AppColors.teal,
                            size: 30.sp,
                          ),
                        ),
                        for (final place in _visiblePlaces)
                          Marker(
                            point: place.point,
                            width: 44,
                            height: 48,
                            child: IconButton(
                              tooltip: place.name,
                              padding: EdgeInsets.zero,
                              onPressed: () => _selectPlace(place),
                              icon: Icon(
                                _typeIcon(place.type),
                                color: _typeColor(place.type),
                                size: 34.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading && _userLocation != null)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: const LinearProgressIndicator(),
            ),
          if (_errorMessage != null && _userLocation != null)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                _errorMessage!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          if (_selectedPlace != null) _selectedPlaceCard(_selectedPlace!),
          SizedBox(height: 14.h),
          Text('Nearby places', style: AppTextStyles.heading2),
          SizedBox(height: 8.h),
          if (_visiblePlaces.isEmpty && !_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No nearby places were found in OpenStreetMap data.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openGoogleMapsFallback,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Search Google Maps instead'),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Google Maps will receive this search and your location, if available.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          for (final place in _visiblePlaces)
            Card(
              color: AppColors.card,
              child: ListTile(
                leading: Icon(
                  _typeIcon(place.type),
                  color: _typeColor(place.type),
                ),
                title: Text(place.name, style: AppTextStyles.labelMedium),
                subtitle: Text(_typeLabel(place.type)),
                onTap: () => _selectPlace(place),
              ),
            ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _PlaceType? type) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedType == type,
        onSelected: (_) => setState(() {
          _selectedType = type;
          _selectedPlace = null;
        }),
      ),
    );
  }

  Widget _selectedPlaceCard(_NearbyPlace place) {
    return Card(
      color: AppColors.card,
      margin: EdgeInsets.only(top: 12.h),
      child: ListTile(
        leading: Icon(_typeIcon(place.type), color: _typeColor(place.type)),
        title: Text(place.name, style: AppTextStyles.labelMedium),
        subtitle: Text(
          '${_typeLabel(place.type)} · ${place.point.latitude.toStringAsFixed(5)}, '
          '${place.point.longitude.toStringAsFixed(5)}',
        ),
        trailing: IconButton(
          tooltip: 'Close place details',
          onPressed: () => setState(() => _selectedPlace = null),
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}
