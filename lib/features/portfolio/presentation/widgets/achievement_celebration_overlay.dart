import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';

/// A full-screen celebration shown the moment one or more achievements are
/// newly unlocked (see `PortfolioController.newlyUnlocked`) — the "reward
/// effects" moment the app was otherwise missing: achievements were unlocked
/// silently before this, with no on-screen acknowledgement at all.
class AchievementCelebrationOverlay extends StatefulWidget {
  const AchievementCelebrationOverlay({super.key, required this.achievements, required this.onDismiss});

  final List<Achievement> achievements;
  final VoidCallback onDismiss;

  @override
  State<AchievementCelebrationOverlay> createState() => _AchievementCelebrationOverlayState();
}

class _AchievementCelebrationOverlayState extends State<AchievementCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.4, curve: Curves.easeOut),
  );

  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _controller.forward();
    _autoDismissTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final totalXp = widget.achievements.fold<int>(0, (sum, a) => sum + a.xpReward);
    final isSingle = widget.achievements.length == 1;

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: tokens.overlay,
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: GestureDetector(
              onTap: () {}, // absorb taps so the card itself doesn't dismiss-through
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: GlassCard(
                  backgroundColor: tokens.surfaceElevated.withValues(alpha: context.isDarkMode ? 0.85 : 0.96),
                  borderColor: AppColors.goldenBorder.withValues(alpha: 0.7),
                  borderRadius: 24,
                  borderWidth: 1.5,
                  boxShadow: [
                    BoxShadow(color: AppColors.goldenBorder.withValues(alpha: 0.35), blurRadius: 30, spreadRadius: 4),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SparkleBurst(controller: _controller),
                        const SizedBox(height: 8),
                        Text(
                          isSingle ? 'Conquista Desbloqueada!' : 'Conquistas Desbloqueadas!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        for (final achievement in widget.achievements) _AchievementRow(achievement: achievement),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.goldenBorder.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+$totalXp XP',
                            style: const TextStyle(color: AppColors.goldenBorder, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Toque para continuar', style: TextStyle(color: tokens.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.goldenBorder.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldenBorder.withValues(alpha: 0.5)),
            ),
            child: Icon(achievement.icon, color: AppColors.goldenBorder, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(achievement.description, style: TextStyle(color: tokens.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A handful of sparkle icons radiating outward as the card scales in.
class _SparkleBurst extends StatelessWidget {
  const _SparkleBurst({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 6; i++) _sparkle(i),
              Icon(Icons.emoji_events, color: AppColors.goldenBorder, size: 44),
            ],
          );
        },
      ),
    );
  }

  Widget _sparkle(int index) {
    final angle = (index / 6) * 2 * pi;
    final distance = 34 * controller.value;
    final opacity = (1 - controller.value).clamp(0.0, 1.0);
    return Transform.translate(
      offset: Offset(cos(angle) * distance, sin(angle) * distance),
      child: Opacity(
        opacity: opacity,
        child: Icon(Icons.auto_awesome, color: AppColors.neonCyan, size: 14),
      ),
    );
  }
}
