import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';

import 'portfolio_test_fixtures.dart';

void main() {
  group('AchievementCatalog.qualifiedIds — empty portfolio', () {
    test('nothing qualifies with no holdings at all', () {
      expect(AchievementCatalog.qualifiedIds(PortfolioStats.empty), isEmpty);
    });
  });

  group('AchievementCatalog.qualifiedIds — value/gain thresholds', () {
    test('first_investment qualifies as soon as there is any holding', () {
      final stats = statsFromLots([lot(quantity: 1, purchasePrice: 1)]);
      expect(AchievementCatalog.qualifiedIds(stats), contains('first_investment'));
    });

    test('positive_return only qualifies once total gain is actually positive', () {
      final flat = statsFromLots([lot(quantity: 10, purchasePrice: 10, currentPrice: 10)]);
      final up = statsFromLots([lot(quantity: 10, purchasePrice: 10, currentPrice: 12)]);

      expect(AchievementCatalog.qualifiedIds(flat), isNot(contains('positive_return')));
      expect(AchievementCatalog.qualifiedIds(up), contains('positive_return'));
    });

    test('portfolio_10k requires at least R\$10,000 in current value, not a cent less', () {
      final justUnder = statsFromLots([lot(quantity: 999, purchasePrice: 10)]); // 9,990
      final exactly = statsFromLots([lot(quantity: 1000, purchasePrice: 10)]); // 10,000

      expect(AchievementCatalog.qualifiedIds(justUnder), isNot(contains('portfolio_10k')));
      expect(AchievementCatalog.qualifiedIds(exactly), contains('portfolio_10k'));
    });

    test('portfolio_50k does not qualify for a portfolio that only clears the 10k bar', () {
      final stats = statsFromLots([lot(quantity: 1500, purchasePrice: 10)]); // 15,000
      final ids = AchievementCatalog.qualifiedIds(stats);
      expect(ids, contains('portfolio_10k'));
      expect(ids, isNot(contains('portfolio_50k')));
    });
  });

  group('AchievementCatalog.qualifiedIds — diversification and ETF collector', () {
    test('diversification_master requires 4+ distinct asset types', () {
      final threeTypes = statsFromLots([
        lot(id: 1, ticker: 'A', type: InvestmentTypeEnum.STOCKS),
        lot(id: 2, ticker: 'B', type: InvestmentTypeEnum.FIXED_INCOME),
        lot(id: 3, ticker: 'C', type: InvestmentTypeEnum.REAL_ESTATE),
      ]);
      final fourTypes = statsFromLots([
        lot(id: 1, ticker: 'A', type: InvestmentTypeEnum.STOCKS),
        lot(id: 2, ticker: 'B', type: InvestmentTypeEnum.FIXED_INCOME),
        lot(id: 3, ticker: 'C', type: InvestmentTypeEnum.REAL_ESTATE),
        lot(id: 4, ticker: 'D', type: InvestmentTypeEnum.FUNDS),
      ]);

      expect(AchievementCatalog.qualifiedIds(threeTypes), isNot(contains('diversification_master')));
      expect(AchievementCatalog.qualifiedIds(fourTypes), contains('diversification_master'));
    });

    test('etf_collector requires 3+ distinct FUNDS tickers specifically', () {
      final twoFunds = statsFromLots([
        lot(id: 1, ticker: 'ETF1', type: InvestmentTypeEnum.FUNDS),
        lot(id: 2, ticker: 'ETF2', type: InvestmentTypeEnum.FUNDS),
      ]);
      final threeFunds = statsFromLots([
        lot(id: 1, ticker: 'ETF1', type: InvestmentTypeEnum.FUNDS),
        lot(id: 2, ticker: 'ETF2', type: InvestmentTypeEnum.FUNDS),
        lot(id: 3, ticker: 'ETF3', type: InvestmentTypeEnum.FUNDS),
      ]);

      expect(AchievementCatalog.qualifiedIds(twoFunds), isNot(contains('etf_collector')));
      expect(AchievementCatalog.qualifiedIds(threeFunds), contains('etf_collector'));
    });
  });

  group('AchievementCatalog.qualifiedIds — dividend_hunter', () {
    test('requires at least R\$1,000/year in estimated passive income', () {
      // Fixed income assumed yield is 11%/yr — R$9,000 * 11% ≈ R$990 (just under).
      final justUnder = statsFromLots([lot(type: InvestmentTypeEnum.FIXED_INCOME, quantity: 900, purchasePrice: 10)]);
      // R$10,000 * 11% = R$1,100 (over).
      final over = statsFromLots([lot(type: InvestmentTypeEnum.FIXED_INCOME, quantity: 1000, purchasePrice: 10)]);

      expect(AchievementCatalog.qualifiedIds(justUnder), isNot(contains('dividend_hunter')));
      expect(AchievementCatalog.qualifiedIds(over), contains('dividend_hunter'));
    });
  });

  group('AchievementCatalog.totalXpFor', () {
    test('an empty unlocked set grants zero XP', () {
      expect(AchievementCatalog.totalXpFor({}), 0);
    });

    test('an unknown id contributes nothing (never throws)', () {
      expect(AchievementCatalog.totalXpFor({'not_a_real_id'}), 0);
    });

    test('wealth/profit/income-tied achievements grant zero XP (DECISION-014)', () {
      // Kept as unlockable milestones for flavor, but must never feed the
      // XP total — XP can only ever come from learning/practice behavior.
      final total = AchievementCatalog.totalXpFor({
        'positive_return',
        'portfolio_10k',
        'portfolio_50k',
        'first_dividend',
        'dividend_hunter',
      });
      expect(total, 0);
    });

    test('investment-activity achievements also grant zero XP (DECISION-027)', () {
      // Unlike DECISION-014's wealth/profit/income signals, these don't
      // reference dollar amounts — but they still reward doing more
      // investing rather than learning, which XP must never do either.
      final total = AchievementCatalog.totalXpFor({
        'first_investment',
        'diversification_master',
        'etf_collector',
        'hundred_days',
        'long_term_investor',
      });
      expect(total, 0);
    });

    test('every achievement in the catalog is zero-XP (DECISION-014 + DECISION-027)', () {
      // The achievement catalog is entirely portfolio-derived (see
      // FEATURES.md's XP System status), so — until it grows a
      // learning/practice-gated condition — no achievement should ever
      // contribute to the XP/level total.
      final allIds = AchievementCatalog.resolve({}).map((a) => a.id).toSet();
      expect(AchievementCatalog.totalXpFor(allIds), 0);
    });
  });

  group('AchievementCatalog.resolve — permanence', () {
    test('every catalog entry is present in the resolved list, unlocked or not', () {
      final resolved = AchievementCatalog.resolve({});
      expect(resolved, isNotEmpty);
      expect(resolved.every((a) => !a.unlocked), isTrue);
    });

    test('an id present in the persisted map is unlocked regardless of current qualification', () {
      // Permanence contract: resolve() takes no live stats at all — an
      // achievement already recorded as unlocked can never un-unlock, because
      // there is no code path here that could take it away.
      final unlockedAt = {'portfolio_50k': DateTime(2025, 1, 1)};
      final resolved = AchievementCatalog.resolve(unlockedAt);

      final entry = resolved.firstWhere((a) => a.id == 'portfolio_50k');
      expect(entry.unlocked, isTrue);
      expect(entry.unlockedAt, DateTime(2025, 1, 1));
    });
  });
}
