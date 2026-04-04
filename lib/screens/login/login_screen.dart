import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _driverIdCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _biometricAvailable = false;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkBiometric();
    _checkExistingSession();
  }

  @override
  void dispose() {
    _driverIdCtrl.dispose();
    _otpCtrl.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final available = await _authService.isBiometricAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _checkExistingSession() async {
    final savedId = await _authService.getStoredDriverId();
    if (savedId != null && savedId.isNotEmpty) {
      _driverIdCtrl.text = savedId;
    }
  }

  Future<void> _sendOtp() async {
    final driverId = _driverIdCtrl.text.trim().toUpperCase();

    if (!RegExp(r'^AMB-\d{4}$').hasMatch(driverId)) {
      _showSnack('Enter a valid Driver ID (AMB-XXXX)');
      return;
    }

    setState(() => _isLoading = true);

    // Fetch driver from Firestore to get phone number
    final driver = await _firestoreService.findByDriverId(driverId);
    if (driver == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Driver ID not found. Please register first.');
      return;
    }

    // Send OTP to stored phone number
    await _authService.sendOtp(
      phone: driver.phone,
      onCodeSent: () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
        _showSnack('OTP sent to ${driver.phone}');
      },
      onError: (err) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack('Failed to send OTP: $err');
      },
    );
  }

  Future<void> _verifyAndLogin() async {
    if (_otpCtrl.text.trim().length != 6) {
      _showSnack('Enter 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    final verified = await _authService.verifyOtp(_otpCtrl.text.trim());
    if (!verified) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Invalid OTP');
      return;
    }

    await _loadDriverAndNavigate();
  }

  Future<void> _biometricLogin() async {
    final driverId = _driverIdCtrl.text.trim().toUpperCase();
    if (driverId.isEmpty) {
      _showSnack('Enter your Driver ID first');
      return;
    }

    final auth = await _authService.authenticateWithBiometric();
    if (!auth) {
      _showSnack('Biometric authentication failed');
      return;
    }

    setState(() => _isLoading = true);
    await _loadDriverAndNavigate();
  }

  Future<void> _loadDriverAndNavigate() async {
    final driverId = _driverIdCtrl.text.trim().toUpperCase();
    final driver = await _firestoreService.findByDriverId(driverId);

    if (driver == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Could not load driver profile');
      return;
    }

    // Update FCM token
    final fcmToken = await NotificationService().getFcmToken();
    if (fcmToken != null && fcmToken.isNotEmpty) {
      await _firestoreService.updateFcmToken(driverId, fcmToken);
    }

    await _authService.saveDriverId(driverId);

    if (!mounted) return;
    context.read<AppProvider>().setDriver(
          fcmToken != null ? driver.copyWith(fcmToken: fcmToken) : driver,
        );
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.body),
        backgroundColor: AppColors.card,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 40),
              Text('DRIVER LOGIN', style: AppTextStyles.display),
              const SizedBox(height: 4),
              Text(
                'Authenticate to access the corridor system',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 36),

              // Driver ID field
              Text('DRIVER ID', style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextField(
                controller: _driverIdCtrl,
                enabled: !_otpSent,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8),
                  UpperCaseTextFormatter(),
                ],
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 3,
                ),
                decoration: InputDecoration(
                  hintText: 'AMB-XXXX',
                  hintStyle: AppTextStyles.h2.copyWith(
                    color: AppColors.textDim,
                    letterSpacing: 3,
                  ),
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.accent,
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.accent, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // OTP section
              if (!_otpSent) ...[
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        children: [
                          _buildPrimaryButton('SEND OTP', _sendOtp),
                          if (_biometricAvailable) ...[
                            const SizedBox(height: 16),
                            _buildBiometricButton(),
                          ],
                        ],
                      ),
              ] else ...[
                Text('ENTER OTP', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.display.copyWith(letterSpacing: 12),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '— — — — — —',
                    hintStyle: AppTextStyles.h2.copyWith(
                      color: AppColors.textDim,
                      letterSpacing: 8,
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        children: [
                          _buildPrimaryButton(
                              'VERIFY & LOGIN', _verifyAndLogin),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                                _otpCtrl.clear();
                              });
                            },
                            child: Text(
                              'Change Driver ID',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textSecond),
                            ),
                          ),
                        ],
                      ),
              ],

              const SizedBox(height: 32),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/register'),
                  child: Text(
                    'New driver? Register here',
                    style: AppTextStyles.body.copyWith(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASTRA',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              Text(
                'Adaptive Signal Traffic Response',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _biometricLogin,
        icon: const Icon(Icons.fingerprint, color: AppColors.accent, size: 22),
        label: Text(
          'USE FINGERPRINT',
          style: AppTextStyles.button.copyWith(color: AppColors.accent),
        ),
      ),
    );
  }
}

// Helper formatter for uppercase driver ID input
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
