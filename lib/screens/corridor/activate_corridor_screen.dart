import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/mysuru_hospitals.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/location_service.dart';

class ActivateCorridorScreen extends StatefulWidget {
  const ActivateCorridorScreen({super.key});

  @override
  State<ActivateCorridorScreen> createState() => _ActivateCorridorScreenState();
}

class _ActivateCorridorScreenState extends State<ActivateCorridorScreen> {
  String _priority = 'CRITICAL';
  final _conditionCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  MysyruHospital? _selectedHospital;
  List<MysyruHospital> _filteredHospitals = mysyruHospitals;

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isActivating = false;

  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _searchCtrl.addListener(_filterHospitals);
  }

  @override
  void dispose() {
    _conditionCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = pos;
        _isLoadingLocation = false;
      });
    }
  }

  void _filterHospitals() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredHospitals = mysyruHospitals
          .where((h) => h.name.toLowerCase().contains(q))
          .toList();
    });
  }

  double? _distanceTo(MysyruHospital hospital) {
    if (_currentPosition == null) return null;
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      hospital.lat,
      hospital.lng,
    );
  }

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  Future<void> _activateCorridor() async {
    if (_selectedHospital == null) return;
    setState(() => _isActivating = true);

    final provider = context.read<AppProvider>();
    final success = await provider.activateCorridor(
      hospitalName: _selectedHospital!.name,
      hospitalLat: _selectedHospital!.lat,
      hospitalLng: _selectedHospital!.lng,
      priority: _priority,
      patientCondition: _conditionCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isActivating = false);

    if (success) {
      // Add a notification entry
      provider.addNotification(
        '🚨 Corridor activated → ${_selectedHospital!.name}',
      );
      Navigator.pop(context);
    } else {
      _showSnack(
        'Backend unreachable — verify ngrok URL in app_config.dart',
      );
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.body),
        backgroundColor: AppColors.card,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textSecond),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ACTIVATE CORRIDOR', style: AppTextStyles.h3),
            Text('Select destination & priority',
                style: AppTextStyles.caption),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Priority Selector ──────────────────────────
                  Text('PRIORITY LEVEL', style: AppTextStyles.label),
                  const SizedBox(height: 10),
                  _buildPrioritySelector(),

                  const SizedBox(height: 20),

                  // ── Patient Condition ──────────────────────────
                  Text('PATIENT CONDITION', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _conditionCtrl,
                    maxLines: 2,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText:
                          'Briefly describe condition (e.g. Cardiac arrest, trauma)',
                      hintStyle: AppTextStyles.bodySmall,
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.accent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Hospital Search ────────────────────────────
                  Text('SELECT HOSPITAL', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchCtrl,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Search hospital...',
                      hintStyle: AppTextStyles.bodySmall,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textDim,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.accent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Hospital List ──────────────────────────────
                  if (_isLoadingLocation)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.accent),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._filteredHospitals.map(
                      (h) => _buildHospitalTile(h),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ── Confirm Bar (when hospital selected) ──────────────
          if (_selectedHospital != null) _buildConfirmBar(),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    const priorities = ['CRITICAL', 'URGENT', 'NORMAL'];
    const colors = [AppColors.primary, AppColors.orange, AppColors.accent];
    const icons = [
      Icons.emergency,
      Icons.priority_high,
      Icons.local_hospital_outlined,
    ];

    return Row(
      children: List.generate(priorities.length, (i) {
        final selected = _priority == priorities[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = priorities[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? colors[i].withValues(alpha: 0.15)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? colors[i] : AppColors.cardBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icons[i],
                      color: selected ? colors[i] : AppColors.textDim,
                      size: 20),
                  const SizedBox(height: 6),
                  Text(
                    priorities[i],
                    style: AppTextStyles.caption.copyWith(
                      color: selected ? colors[i] : AppColors.textDim,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHospitalTile(MysyruHospital hospital) {
    final isSelected = _selectedHospital == hospital;
    final dist = _distanceTo(hospital);

    return GestureDetector(
      onTap: () => setState(() => _selectedHospital = hospital),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGlow : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_hospital,
                color: isSelected ? AppColors.primary : AppColors.textDim,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hospital.name, style: AppTextStyles.body),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: hospital.type == 'Govt'
                              ? AppColors.accentGlow
                              : AppColors.greenGlow,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          hospital.type,
                          style: AppTextStyles.caption.copyWith(
                            color: hospital.type == 'Govt'
                                ? AppColors.accent
                                : AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (dist != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDistance(dist),
                    style: AppTextStyles.body.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecond,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('away', style: AppTextStyles.caption),
                ],
              ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DESTINATION', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      _selectedHospital!.name,
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _priorityColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _priorityColor().withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _priority,
                  style: AppTextStyles.caption.copyWith(
                    color: _priorityColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: _isActivating ? null : _activateCorridor,
              icon: _isActivating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.emergency_share, color: Colors.white),
              label: Text(
                _isActivating
                    ? 'ACTIVATING...'
                    : 'CONFIRM & ACTIVATE',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor() {
    switch (_priority) {
      case 'CRITICAL':
        return AppColors.primary;
      case 'URGENT':
        return AppColors.orange;
      default:
        return AppColors.accent;
    }
  }
}
