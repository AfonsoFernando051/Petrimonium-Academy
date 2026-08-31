import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_evolution_rule.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/widgets/pet_mascot_widget.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Shows how the companion is progressing (driven purely by learning/
/// practice XP — never net worth, `docs/PRODUCT_VISION.md` §9/§11) next to
/// real portfolio context. Net worth is shown as a plain informational
/// stat, not an evolution input.
class RpgIntegrationCard extends StatelessWidget {
  const RpgIntegrationCard({
    super.key,
    required this.controller,
    required this.stats,
    required this.currentStreak,
    this.showPetVisual = true,
  });

  final MascotController controller;
  final PortfolioStats stats;

  /// The real consecutive-day engagement streak from the backend
  /// (`GamificationSummary.currentStreak`) — not derived client-side.
  final int currentStreak;

  /// The Home dashboard already shows the user's actual chosen pet species
  /// via `PetShowcase` (the mascot evolution art in `PetMascotWidget` isn't
  /// produced yet and always falls back to a generic dog regardless of
  /// species — see `assets/mascot/evolutions/`, currently empty). Passing
  /// `false` here avoids rendering that fallback a second time right next
  /// to the real pet and keeps this card focused on the numbers.
  final bool showPetVisual;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final tokens = context.colors;
        final profile = controller.profile;
        final nextRule = PetEvolutionRule.defaultRules.firstWhere(
          (r) => r.stage.tier > profile.stage.tier,
          orElse: () => PetEvolutionRule.defaultRules.last,
        );
        final hasNext = nextRule.stage != profile.stage;
        final xpProgress =
            hasNext && nextRule.minXp > 0 ? (profile.xp / nextRule.minXp).clamp(0.0, 1.0) : 1.0;

        return GlassCard(
          backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.65 : 0.94),
          borderColor: AppColors.neonViolet.withValues(alpha: 0.4),
          borderRadius: 20,
          borderWidth: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('EVOLUÇÃO DO COMPANHEIRO'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showPetVisual) ...[
                      PetMascotWidget(controller: controller, size: 110),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.stage.label,
                            style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Tier ${profile.stage.tier}/9',
                            style: TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          _progressLine(
                            context: context,
                            label: hasNext ? 'XP até a próxima evolução' : 'Evolução máxima',
                            value: xpProgress,
                            trailing: hasNext ? '${profile.xp}/${nextRule.minXp} XP' : '${profile.xp} XP',
                            color: AppColors.goldenBorder,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _statTile(context, Icons.account_balance_wallet, 'Patrimônio', AppFormatters.compactCurrency(profile.netWorth))),
                    Expanded(child: _statTile(context, Icons.local_fire_department, 'Sequência', '$currentStreak dias')),
                    Expanded(child: _statTile(context, Icons.hub, 'Diversificação', '${stats.distinctTypeCount} categorias')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _progressLine({
    required BuildContext context,
    required String label,
    required double value,
    required String trailing,
    required Color color,
  }) {
    final tokens = context.colors;
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: TextStyle(color: tokens.textSecondary, fontSize: 10)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 6, color: tokens.textTertiary.withValues(alpha: 0.18)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, animated, _) => FractionallySizedBox(
                    widthFactor: animated,
                    child: Container(height: 6, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(trailing, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statTile(BuildContext context, IconData icon, String label, String value) {
    final tokens = context.colors;
    return Column(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
        Text(label, style: TextStyle(color: tokens.textSecondary, fontSize: 9)),
      ],
    );
  }
}
