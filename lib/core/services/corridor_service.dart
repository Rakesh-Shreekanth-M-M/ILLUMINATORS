import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../config/app_config.dart';

class CorridorService {
  WebSocketChannel? _wsChannel;

  // ── REST API Calls ────────────────────────────────

  Future<Map<String, dynamic>> activateCorridor({
    required String driverName,
    required String vehicleId,
    required String contact,
    required String hospitalName,
    required double hospitalLat,
    required double hospitalLng,
    required String priority,
    required String patientCondition,
  }) async {
    final response = await http
        .post(
          Uri.parse('${AppConfig.backendUrl}/corridor/activate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'driver_name': driverName,
            'vehicle_id': vehicleId,
            'contact': contact,
            'hospital_name': hospitalName,
            'hospital_lat': hospitalLat,
            'hospital_lng': hospitalLng,
            'priority': priority,
            'patient_condition': patientCondition,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Activate failed: ${response.statusCode}');
  }

  Future<void> deactivateCorridor() async {
    try {
      await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/corridor/deactivate'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Best effort
    }
  }

  Future<Map<String, dynamic>?> getStatus() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.backendUrl}/corridor/status'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // ── WebSocket ─────────────────────────────────────

  Stream<dynamic>? connectWebSocket() {
    try {
      final wsUrl = AppConfig.backendUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/ws/signal'),
      );
      return _wsChannel!.stream;
    } catch (_) {
      return null;
    }
  }

  void disconnectWebSocket() {
    _wsChannel?.sink.close();
    _wsChannel = null;
  }
}
