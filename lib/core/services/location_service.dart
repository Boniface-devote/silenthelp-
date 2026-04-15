import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CachedLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? address;
  final DateTime timestamp;

  CachedLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CachedLocation.fromJson(Map<String, dynamic> json) {
    return CachedLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double,
      address: json['address'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class LocationService {
  static const String _cacheKey = 'silenthelp_cached_location';
  static const Duration _cacheValidity = Duration(minutes: 5);
  static const int _maxRetries = 3;
  static const double _accuracyThreshold = 50.0; // meters

  /// Check if location permission is granted, request if needed
  static Future<bool> ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      return false;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get last known location from device
  static Future<Position?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      print('Error getting last known position: $e');
      return null;
    }
  }

  /// Get cached location from SharedPreferences
  static Future<CachedLocation?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return null;

      final location = CachedLocation.fromJson(jsonDecode(cached));
      
      // Check if cache is still valid
      final age = DateTime.now().difference(location.timestamp);
      if (age > _cacheValidity) {
        return null; // Cache expired
      }

      return location;
    } catch (e) {
      print('Error reading cached location: $e');
      return null;
    }
  }

  /// Cache location to SharedPreferences
  static Future<void> cacheLocation(CachedLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(location.toJson()));
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  /// Get high accuracy location with retries for better accuracy
  static Future<Position?> getHighAccuracyLocation({
    int maxRetries = _maxRetries,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        ).timeout(timeout);

        // If accuracy is good enough, return
        if (position.accuracy <= _accuracyThreshold) {
          return position;
        }

        // If not the last attempt, wait before retrying
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      } catch (e) {
        print('Location attempt $attempt failed: $e');
        if (attempt == maxRetries - 1) {
          // Last attempt failed, return fallback
          return Position(
            latitude: 0.3,
            longitude: 32.6,
            timestamp: DateTime.now(),
            accuracy: 999,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }
    }

    return null;
  }

  /// Get location with low accuracy (for background tracking)
  static Future<Position?> getLowAccuracyLocation({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(timeout);
      return position;
    } catch (e) {
      print('Low accuracy location error: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to address string
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[];

      if (place.street != null && place.street!.isNotEmpty) {
        parts.add(place.street!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }

      return parts.isNotEmpty ? parts.join(', ') : null;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }

  /// Get full location (coordinates + address) and cache it
  static Future<CachedLocation?> getFullLocation({
    bool highAccuracy = false,
  }) async {
    try {
      final position = highAccuracy
          ? await getHighAccuracyLocation()
          : await getLowAccuracyLocation();

      if (position == null) return null;

      // Get address in parallel
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final location = CachedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
        timestamp: DateTime.now(),
      );

      // Cache it for faster future access
      await cacheLocation(location);

      return location;
    } catch (e) {
      print('Error getting full location: $e');
      return null;
    }
  }

  /// Initialize location service on app launch
  static Future<void> initialize() async {
    try {
      // Check permission first
      final hasPermission = await ensureLocationPermission();
      if (!hasPermission) {
        print('Location permission not granted');
        return;
      }

      // Try to get last known location
      final lastKnownPos = await getLastKnownLocation();
      if (lastKnownPos != null) {
        final address = await getAddressFromCoordinates(
          lastKnownPos.latitude,
          lastKnownPos.longitude,
        );

        final location = CachedLocation(
          latitude: lastKnownPos.latitude,
          longitude: lastKnownPos.longitude,
          accuracy: lastKnownPos.accuracy,
          address: address,
          timestamp: lastKnownPos.timestamp ?? DateTime.now(),
        );

        await cacheLocation(location);
        print('Initialized location service with cached position');
      }

      // Start passive location tracking
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          distanceFilter: 50, // Update every 50 meters
        ),
      ).listen((position) {
        // Update cache in background
        _updateLocationCache(position);
      });
    } catch (e) {
      print('Location service initialization error: $e');
    }
  }

  static Future<void> _updateLocationCache(Position position) async {
    try {
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final location = CachedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
        timestamp: position.timestamp ?? DateTime.now(),
      );

      await cacheLocation(location);
      print('Background location updated: ${location.accuracy}m accuracy');
    } catch (e) {
      print('Error updating location cache: $e');
    }
  }
}
