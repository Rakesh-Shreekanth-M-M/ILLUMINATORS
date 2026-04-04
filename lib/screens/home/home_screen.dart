import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/auth_service.dart';
import 'widgets/corridor_status_card.dart';
import 'widgets/notification_bell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNotificationsPanel(BuildContext context, AppProvider provider) {
    provider.clearNotificationBadge();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NotificationsSheet(
        notifications: provider.notifications,
        wsMessages: provider.wsMessages,
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text('Cancel Corridor?', style: AppTextStyles.h2),
        content: Text(
          'This will deactivate the green corridor and stop signal priority.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecond),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Active',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecond),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await provider.deactivateCorridor();
            },
            child: Text('CANCEL CORRIDOR', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final driver = provider.driver;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top Bar ─────────────────────────────────
                        Row(
                          children: [
                            // Profile photo
                            GestureDetector(
                              onTap: () => _showProfileSheet(context, provider),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      driver?.profilePhotoUrl.isNotEmpty == true
                                          ? CachedNetworkImage(
                                              imageUrl: driver!.profilePhotoUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) => Container(
                                                color: AppColors.card,
                                              ),
                                            )
                                          : Container(
                                              color: AppColors.card,
                                              child: const Icon(
                                                Icons.person,
                                                color: AppColors.textSecond,
                                                size: 22,
                                              ),
                                            ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver?.fullName ?? 'Driver',
                                    style: AppTextStyles.h3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    driver?.vehiclePlate ?? '',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // AMB badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGlow,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                driver?.driverId ?? '—',
                                style: AppTextStyles.badge,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Notifications bell
                            NotificationBell(
                              count: provider.notificationCount,
                              onTap: () =>
                                  _showNotificationsPanel(context, provider),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── System Status Row ────────────────────────
                        _buildSystemStatusRow(provider.isCorridorActive),

                        const SizedBox(height: 20),

                        // ── Corridor Status Card ─────────────────────
                        CorridorStatusCard(
                          isActive: provider.isCorridorActive,
                          hospitalName: provider.activeHospital,
                          priority: provider.activePriority,
                        ),

                        const SizedBox(height: 20),

                        // ── Cancel button (when active) ──────────────
                        if (provider.isCorridorActive)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () =>
                                  _showCancelDialog(context, provider),
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'CANCEL CORRIDOR',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // ── Live Signal Feed (when active) ───────────
                        if (provider.isCorridorActive &&
                            provider.wsMessages.isNotEmpty)
                          _buildSignalFeed(provider.wsMessages),

                        // ── Quick Stats ──────────────────────────────
                        _buildQuickStats(driver?.vehiclePlate ?? '—'),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FAB — Activate Corridor
          floatingActionButton: !provider.isCorridorActive
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryGlow,
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 56,
                    child: FloatingActionButton.extended(
                      heroTag: 'activate_fab',
                      backgroundColor: AppColors.primary,
                      icon: const Icon(
                        Icons.emergency_share,
                        color: Colors.white,
                      ),
                      label: Text(
                        'ACTIVATE CORRIDOR',
                        style: AppTextStyles.button,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/activate'),
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildSystemStatusRow(bool corridorActive) {
    return Row(
      children: [
        _statusChip(
          'ESP32',
          Icons.developer_board,
          AppColors.green,
        ),
        const SizedBox(width: 8),
        _statusChip(
          'YOLOv8',
          Icons.remove_red_eye_outlined,
          AppColors.accent,
        ),
        const SizedBox(width: 8),
        _statusChip(
          corridorActive ? 'ACTIVE' : 'STANDBY',
          corridorActive ? Icons.wifi_tethering : Icons.wifi_tethering_off,
          corridorActive ? AppColors.primary : AppColors.textDim,
        ),
      ],
    );
  }

  Widget _statusChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalFeed(List<String> messages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SIGNAL FEED', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: messages
                .take(5)
                .map(
                  (msg) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.traffic,
                          color: AppColors.green,
                          size: 12,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(msg, style: AppTextStyles.bodySmall),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildQuickStats(String vehiclePlate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VEHICLE INFO', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'PLATE',
                vehiclePlate,
                Icons.local_shipping_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'SYSTEM',
                'ASTRA v1.0',
                Icons.electrical_services,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textDim, size: 18),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.h3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context, AppProvider provider) {
    final driver = provider.driver;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('DRIVER PROFILE', style: AppTextStyles.label),
            const SizedBox(height: 16),
            _profileRow('Driver ID', driver?.driverId ?? '—'),
            _profileRow('Name', driver?.fullName ?? '—'),
            _profileRow('Phone', driver?.phone ?? '—'),
            _profileRow('Vehicle', driver?.vehiclePlate ?? '—'),
            _profileRow('Licence', driver?.licence ?? '—'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await AuthService().signOut();
                  provider.clearDriver();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.primary),
                label: Text(
                  'SIGN OUT',
                  style:
                      AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notifications Sheet ────────────────────────────────────────────────────────

class _NotificationsSheet extends StatelessWidget {
  final List<String> notifications;
  final List<String> wsMessages;

  const _NotificationsSheet({
    required this.notifications,
    required this.wsMessages,
  });

  @override
  Widget build(BuildContext context) {
    final all = [
      ...notifications,
      ...wsMessages.map((m) => '📡 Signal update: $m'),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Text('PROXIMITY ALERTS', style: AppTextStyles.h3),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textSecond,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.divider, height: 1),
        if (all.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: AppColors.textDim,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text('No alerts yet', style: AppTextStyles.bodySmall),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: all.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.divider, height: 1),
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.primary),
              title: Text(all[i], style: AppTextStyles.body),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
