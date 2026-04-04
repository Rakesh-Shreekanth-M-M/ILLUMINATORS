// ─────────────────────────────────────────────────
// ASTRA — App Configuration
// Change backendUrl to your current ngrok URL before demo
// ─────────────────────────────────────────────────

class AppConfig {
  // 🔧 UPDATE THIS before every demo session
  static const String backendUrl = 'http://YOUR_NGROK_URL_HERE';

  // GPS coordinates for demo signal (Mysuru Ring Road signal)
  static const double signalLat = 12.3051;
  static const double signalLng = 76.6551;

  // Proximity radius in meters
  static const double proximityRadiusMeters = 300.0;

  // Location update interval when corridor is active
  static const int locationIntervalSeconds = 10;

  // Firebase project ID (for reference)
  static const String firebaseProjectId = 'astra-94fe7';
}
