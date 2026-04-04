import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'drivers';

  // ── Write ─────────────────────────────────────────

  Future<void> saveDriver(DriverModel driver) async {
    await _db
        .collection(_collection)
        .doc(driver.driverId)
        .set(driver.toMap());
  }

  Future<void> updateFcmToken(String driverId, String token) async {
    await _db
        .collection(_collection)
        .doc(driverId)
        .update({'fcmToken': token});
  }

  // ── Read ──────────────────────────────────────────

  Future<DriverModel?> getDriver(String driverId) async {
    final doc = await _db.collection(_collection).doc(driverId).get();
    if (!doc.exists || doc.data() == null) return null;
    return DriverModel.fromMap(doc.data()!);
  }

  Future<bool> driverExists(String driverId) async {
    final doc = await _db.collection(_collection).doc(driverId).get();
    return doc.exists;
  }

  /// Find driver by Driver ID for login lookup
  Future<DriverModel?> findByDriverId(String driverId) async {
    final doc = await _db.collection(_collection).doc(driverId).get();
    if (!doc.exists || doc.data() == null) return null;
    return DriverModel.fromMap(doc.data()!);
  }
}
