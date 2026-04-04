import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';

class LocationService {
  Timer? _proximityTimer;

  // ── Single GPS Fix ─────────────────────────────────

  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied ||
            req == LocationPermission.deniedForever) {
          return null;
        }
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Distance Calculation (Haversine) ───────────────

  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371.0; // km
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRad(double degree) => degree * pi / 180;

  // ── Proximity Posting ─────────────────────────────

  void startProximityPosting({
    required String driverFcmToken,
  }) {
    stopProximityPosting();
    _proximityTimer = Timer.periodic(
      const Duration(seconds: AppConfig.locationIntervalSeconds),
      (_) => _postProximity(driverFcmToken),
    );
    // Post immediately on start
    _postProximity(driverFcmToken);
  }

  void stopProximityPosting() {
    _proximityTimer?.cancel();
    _proximityTimer = null;
  }

  Future<void> _postProximity(String fcmToken) async {
    try {
      final pos = await getCurrentPosition();
      if (pos == null) return;

      await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/notify/proximity'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'driver_lat': pos.latitude,
              'driver_lng': pos.longitude,
              'signal_lat': AppConfig.signalLat,
              'signal_lng': AppConfig.signalLng,
              'driver_fcm_token': fcmToken,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Silently fail — network issues shouldn't crash the app
    }
  }
}
