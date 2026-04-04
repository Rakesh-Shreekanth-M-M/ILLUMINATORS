import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  String? _verificationId;

  // ── OTP Flow ──────────────────────────────────────

  /// Sends OTP to [phone] (format: +91XXXXXXXXXX)
  /// Calls [onCodeSent] when SMS is dispatched
  /// Calls [onError] on failure
  Future<void> sendOtp({
    required String phone,
    required void Function() onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval on Android (instant OTP)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verifies the [smsCode] entered by the user
  /// Returns true on success
  Future<bool> verifyOtp(String smsCode) async {
    if (_verificationId == null) return false;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // ── Biometric Auth ─────────────────────────────────

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access ASTRA',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ── Local Storage ─────────────────────────────────

  Future<void> saveDriverId(String driverId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_id', driverId);
  }

  Future<String?> getStoredDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('driver_id');
  }

  Future<void> clearDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_id');
  }

  // ── Current User ──────────────────────────────────

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
    await clearDriverId();
  }
}
