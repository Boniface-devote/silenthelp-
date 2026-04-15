import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/services/location_service.dart';

class EmergencyState {
  final CachedLocation? currentLocation;
  final bool isLocationLoading;
  final bool isLocationAccurate; // True if accuracy <= 50m
  final bool isSendingSos;
  final bool sosSent;
  final String? sosUpdateCount; // Track if updated SOS sent

  // Legacy fields for backward compatibility
  Position? get currentPosition =>
      currentLocation != null
          ? Position(
              latitude: currentLocation!.latitude,
              longitude: currentLocation!.longitude,
              timestamp: DateTime.now(),
              accuracy: currentLocation!.accuracy,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            )
          : null;

  String? get locationName => currentLocation?.address;

  EmergencyState({
    this.currentLocation,
    this.isLocationLoading = false,
    this.isLocationAccurate = false,
    this.isSendingSos = false,
    this.sosSent = false,
    this.sosUpdateCount,
  });

  EmergencyState copyWith({
    CachedLocation? currentLocation,
    bool? isLocationLoading,
    bool? isLocationAccurate,
    bool? isSendingSos,
    bool? sosSent,
    String? sosUpdateCount,
  }) {
    return EmergencyState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isLocationAccurate: isLocationAccurate ?? this.isLocationAccurate,
      isSendingSos: isSendingSos ?? this.isSendingSos,
      sosSent: sosSent ?? this.sosSent,
      sosUpdateCount: sosUpdateCount ?? this.sosUpdateCount,
    );
  }
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  EmergencyNotifier() : super(EmergencyState());

  // Load cached location on screen open
  Future<void> loadCachedLocation() async {
    state = state.copyWith(isLocationLoading: true);
    try {
      final cached = await LocationService.getCachedLocation();
      if (cached != null) {
        state = state.copyWith(
          currentLocation: cached,
          isLocationAccurate: cached.accuracy <= 50.0,
        );
      }
    } catch (e) {
      print('Error loading cached location: $e');
    } finally {
      state = state.copyWith(isLocationLoading: false);
    }
  }

  // Refresh location in background (high accuracy)
  Future<void> refreshLocationBackground() async {
    try {
      final location = await LocationService.getFullLocation(
        highAccuracy: true,
      );
      if (location != null) {
        state = state.copyWith(
          currentLocation: location,
          isLocationAccurate: location.accuracy <= 50.0,
        );
        print('Background location refreshed: ${location.accuracy}m accuracy');
      }
    } catch (e) {
      print('Error refreshing location background: $e');
    }
  }

  // Legacy method for backward compatibility
  void setPosition(Position? position) {
    if (position != null) {
      final cached = CachedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );
      state = state.copyWith(currentLocation: cached);
    }
  }

  // Legacy method for backward compatibility
  void setLocationName(String? name) {
    if (state.currentLocation != null && name != null) {
      final updated = CachedLocation(
        latitude: state.currentLocation!.latitude,
        longitude: state.currentLocation!.longitude,
        accuracy: state.currentLocation!.accuracy,
        address: name,
        timestamp: state.currentLocation!.timestamp,
      );
      state = state.copyWith(currentLocation: updated);
    }
  }

  void setSendingSos(bool sending) {
    state = state.copyWith(isSendingSos: sending);
  }

  void setSosSent(bool sent) {
    state = state.copyWith(sosSent: sent);
  }

  void setLocationLoading(bool loading) {
    state = state.copyWith(isLocationLoading: loading);
  }

  void reset() {
    state = EmergencyState();
  }

  /// Get human-readable location name from coordinates using reverse geocoding
  Future<String?> getLocationName(double latitude, double longitude) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build address string: street -> locality -> administrativeArea -> country
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

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }

      return null;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }
}

final emergencyProvider = StateNotifierProvider<EmergencyNotifier, EmergencyState>(
  (ref) => EmergencyNotifier(),
);
