import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/price_status.dart';

/// A single ticker's aggregated position — the sum of every [InvestmentLot]
/// the user holds for that ticker, each of which may have its own purchase
/// date/price. [lots] is kept (oldest first) so the UI can show "historical
/// purchases" and average-price evolution when an asset is expanded.
class Holding {
  final String ticker;
  final InvestmentTypeEnum type;
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final double investedValue;
  final double currentValue;
  final double portfolioPercent;
  final List<InvestmentLot> lots;

  const Holding({
    required this.ticker,
    required this.type,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.investedValue,
    required this.currentValue,
    required this.portfolioPercent,
    required this.lots,
  });

  double get gainValue => currentValue - investedValue;

  double get gainPercent => investedValue == 0 ? 0.0 : (gainValue / investedValue) * 100;

  /// The provenance of this holding's price. Every lot of a given ticker is
  /// priced from the same quote, so they normally agree; when they don't, the
  /// least-trustworthy one wins — a holding is only "live" if all of it is.
  PriceStatus get priceStatus {
    if (lots.any((l) => l.priceStatus == PriceStatus.stalePurchasePrice)) {
      return PriceStatus.stalePurchasePrice;
    }
    if (lots.any((l) => l.priceStatus == PriceStatus.notQuoted)) {
      return PriceStatus.notQuoted;
    }
    return PriceStatus.live;
  }

  /// Whether [gainValue]/[gainPercent] may be presented to the user as a real
  /// return. False means the price is a fallback and any "0%" is an artifact.
  bool get hasLiveQuote => priceStatus.isLive;

  DateTime get firstPurchaseDate =>
      lots.map((l) => l.purchaseDate).reduce((a, b) => a.isBefore(b) ? a : b);

  /// Groups raw lots by ticker and computes each aggregate's share of the
  /// total portfolio current value.
  static List<Holding> fromLots(List<InvestmentLot> lots) {
    final byTicker = <String, List<InvestmentLot>>{};
    for (final lot in lots) {
      byTicker.putIfAbsent(lot.ticker, () => []).add(lot);
    }

    final totalCurrentValue = lots.fold<double>(0, (sum, l) => sum + l.currentValue);

    final holdings = byTicker.entries.map((entry) {
      final tickerLots = entry.value..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
      final quantity = tickerLots.fold<double>(0, (sum, l) => sum + l.quantity);
      final investedValue = tickerLots.fold<double>(0, (sum, l) => sum + l.investedValue);
      final currentValue = tickerLots.fold<double>(0, (sum, l) => sum + l.currentValue);
      final averagePrice = quantity == 0 ? 0.0 : investedValue / quantity;
      final currentPrice = tickerLots.last.currentPrice;

      return Holding(
        ticker: entry.key,
        type: tickerLots.first.type,
        quantity: quantity,
        averagePrice: averagePrice,
        currentPrice: currentPrice,
        investedValue: investedValue,
        currentValue: currentValue,
        portfolioPercent: totalCurrentValue == 0 ? 0.0 : (currentValue / totalCurrentValue) * 100,
        lots: tickerLots,
      );
    }).toList();

    holdings.sort((a, b) => b.currentValue.compareTo(a.currentValue));
    return holdings;
  }
}
