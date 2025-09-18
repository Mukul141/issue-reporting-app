// lib/core/utils/location_helper.dart
// Geolocator-based utility for requesting permissions and fetching the device's
// current position with simple error messages suitable for UI surfacing. [web:151]

import 'package:geolocator/geolocator.dart';

/// Provides a single entry point to acquire the device's current position,
/// handling service checks and permission prompts before resolving. [web:151]
class LocationHelper {
  /// Returns the current [Position] after ensuring location services are
  /// enabled and permissions are granted; throws a descriptive error string
  /// when services are disabled or permissions are denied. [web:152]
  static Future<Position> getCurrentLocation() async {
    // Ensure device location services (GPS) are enabled. [web:151]
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check and request runtime permission if needed. [web:151]
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // Denied forever cannot be requested again; direct users to settings. [web:151]
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, please enable them in settings.',
      );
    }

    // Fetch current position with platform defaults for accuracy/timeout. [web:151]
    return Geolocator.getCurrentPosition();
  }
}
