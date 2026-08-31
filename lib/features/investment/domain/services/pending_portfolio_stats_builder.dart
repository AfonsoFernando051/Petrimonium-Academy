import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';

/// Builds a real `PortfolioStats` snapshot from the assets a user is
/// *currently adding* on the Portfolio Setup screen — before anything is
/// submitted to the backend. This lets the setup screen reuse the exact
/// same domain services the real Dashboard uses (`AchievementCatalog`,
/// `PassiveIncomeEstimator`) to preview real numbers
/// ("this unlocks +50 XP", "≈R$12/month passive income") instead of
/// fabricating separate onboarding-only figures.
///
/// Since nothing is saved yet, there's no live quote for these tickers —
/// `currentPrice` is set equal to `purchasePrice` (no gain/loss yet, which
/// is accurate: from the moment of adding, invested value *is* the current
/// value until a real quote is fetched after saving).
class PendingPortfolioStatsBuilder {
  const PendingPortfolioStatsBuilder._();

  static PortfolioStats build(List<AssetRegistrationModel> assets) {
    if (assets.isEmpty) return PortfolioStats.empty;

    final lots = <InvestmentLot>[
      for (var i = 0; i < assets.length; i++) _toLot(i, assets[i]),
    ];

    final holdings = Holding.fromLots(lots);
    final totalValue = holdings.fold<double>(0, (sum, h) => sum + h.currentValue);

    final byType = <InvestmentTypeEnum, double>{};
    for (final holding in holdings) {
      byType[holding.type] = (byType[holding.type] ?? 0) + holding.currentValue;
    }
    final allocation = byType.entries
        .map((entry) => AllocationSlice(
              type: entry.key,
              currentValue: entry.value,
              portfolioPercent: totalValue == 0 ? 0 : (entry.value / totalValue) * 100,
            ))
        .toList();

    final summary = PortfolioSummary(
      investedCapital: totalValue,
      currentValue: totalValue,
      totalGain: 0,
      totalGainPercent: 0,
      totalAssets: holdings.length,
    );

    return PortfolioStats(summary: summary, holdings: holdings, allocation: allocation);
  }

  static InvestmentLot _toLot(int index, AssetRegistrationModel asset) {
    final investedValue = asset.quantity * asset.purchasePrice;
    return InvestmentLot(
      id: index,
      ticker: asset.name.toUpperCase(),
      type: asset.type,
      quantity: asset.quantity,
      purchasePrice: asset.purchasePrice,
      purchaseDate: DateTime.tryParse(asset.purchaseDate) ?? DateTime.now(),
      currentPrice: asset.purchasePrice,
      investedValue: investedValue,
      currentValue: investedValue,
    );
  }
}
