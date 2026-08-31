import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';

/// The left panel's "what you're about to unlock" checklist. Every item
/// here shares the same unlock condition as the real `first_investment`
/// achievement (having at least one holding) — the +XP figure is pulled
/// from the real `AchievementCatalog` rather than a hardcoded number, so it
/// can never drift out of sync with what actually gets awarded once the
/// user confirms and the Dashboard evaluates achievements for real.
class UnlockableRewardsCard extends StatelessWidget {
  const UnlockableRewardsCard({super.key, required this.stats});

  final PortfolioStats stats;

  @override
  Widget build(BuildContext context) {
    final unlocked = AchievementCatalog.qualifiedIds(stats).contains('first_investment');
    final xp = AchievementCatalog.totalXpFor({'first_investment'});

    final items = [
      'Emblema de Primeiro Investidor',
      '+$xp XP',
      'Missões Diárias',
      'Acompanhamento de Portfólio',
      'Evolução do Pet',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unlocked ? 'Você desbloqueou:' : 'Adicione seu primeiro ativo para desbloquear:',
          style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 10),
        for (final item in items) _RewardRow(label: item, unlocked: unlocked),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.label, required this.unlocked});

  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final color = unlocked ? tokens.success : tokens.textTertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? tokens.success.withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
            ),
            child: unlocked ? Icon(Icons.check, size: 12, color: tokens.success) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? tokens.textPrimary : tokens.textTertiary,
                fontSize: 13,
                fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
