import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';
import 'package:petrimonium/features/portfolio/domain/services/passive_income_estimator.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// Instant, always-visible feedback after every asset add — reuses the same
/// domain services as the real Dashboard (`PassiveIncomeEstimator`,
/// `AchievementCatalog`) so every figure shown here is a real computed
/// preview, not a separate onboarding-only estimate.
class LivePortfolioSummaryCard extends StatelessWidget {
  const LivePortfolioSummaryCard({super.key, required this.stats, required this.alreadyUnlockedIds});

  final PortfolioStats stats;
  final Set<String> alreadyUnlockedIds;

  @override
  Widget build(BuildContext context) {
    final hasAssets = stats.hasHoldings;
    final income = PassiveIncomeEstimator.estimate(stats);
    final qualified = AchievementCatalog.qualifiedIds(stats);
    final newlyQualified = qualified.difference(alreadyUnlockedIds);
    final xp = AchievementCatalog.totalXpFor(newlyQualified);
    final allAchievements = AchievementCatalog.resolve({for (final id in alreadyUnlockedIds) id: DateTime.now()});
    final highlightAchievement = allAchievements.firstWhere(
      (a) => newlyQualified.contains(a.id),
      orElse: () => allAchievements.firstWhere((a) => !a.unlocked, orElse: () => allAchievements.first),
    );
    final highlightIsUnlocked = highlightAchievement.unlocked || newlyQualified.contains(highlightAchievement.id);

    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.3),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Translator.translate(AppStrings.portfolioCardTitle), style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _stat(context, 'Ativos', '${stats.summary.totalAssets}', AppColors.neonCyan)),
                Expanded(child: _stat(context, 'Valor', AppFormatters.compactCurrency(stats.summary.currentValue), AppColors.neonCyan)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _stat(
                    context,
                    'Renda Passiva Est.',
                    hasAssets ? '${AppFormatters.currency(income.monthlyEstimate, showCents: false)}/mês' : '—',
                    AppColors.goldenBorder,
                  ),
                ),
                Expanded(child: _stat(context, 'XP Ganho', '+$xp XP', AppColors.neonPink)),
              ],
            ),
            if (hasAssets) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: highlightIsUnlocked
                      ? context.colors.success.withValues(alpha: 0.1)
                      : context.colors.textPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      highlightIsUnlocked ? Icons.check_circle : highlightAchievement.icon,
                      color: highlightIsUnlocked ? context.colors.success : context.colors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        highlightAchievement.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: highlightIsUnlocked ? context.colors.success : context.colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
