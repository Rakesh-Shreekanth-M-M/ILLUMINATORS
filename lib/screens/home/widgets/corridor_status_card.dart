import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CorridorStatusCard extends StatefulWidget {
  final bool isActive;
  final String hospitalName;
  final String priority;

  const CorridorStatusCard({
    super.key,
    required this.isActive,
    this.hospitalName = '',
    this.priority = '',
  });

  @override
  State<CorridorStatusCard> createState() => _CorridorStatusCardState();
}

class _CorridorStatusCardState extends State<CorridorStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CorridorStatusCard old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && old.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: _buildCard(child!),
        ),
        child: _buildActiveContent(),
      );
    }
    return _buildCard(_buildInactiveContent());
  }

  Widget _buildCard(Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: _glowAnim.value)
                : AppColors.cardBorder,
            width: widget.isActive ? 1.5 : 1,
          ),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: 0.15 * _glowAnim.value),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }

  Widget _buildActiveContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'CORRIDOR ACTIVE',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Text(
                widget.priority,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 16),
        Text('DESTINATION', style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.local_hospital,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.hospitalName,
                style: AppTextStyles.h3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.greenGlow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.traffic, color: AppColors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'SIGNALS CLEARING AHEAD',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.circle_outlined,
                color: AppColors.textDim, size: 10),
            const SizedBox(width: 8),
            Text(
              'NO ACTIVE CORRIDOR',
              style: AppTextStyles.h2.copyWith(color: AppColors.textSecond),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap ACTIVATE CORRIDOR to request green signal priority on your route',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.textDim, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'System ready · ESP32 signals online',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
