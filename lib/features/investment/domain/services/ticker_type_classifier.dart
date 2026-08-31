import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// Best-effort classification of a B3 ticker's asset type from its suffix,
/// mirroring the backend heuristic in `AssetDetailsResponseMapper
/// .detectAssetTypeFromTicker` (11 = FII, 3-8 = stock). Used to catch the
/// user picking a mismatched type card for the ticker they typed — e.g.
/// selecting "Renda Fixa" while entering `HGLG11`, a FII.
///
/// Returns null when the ticker doesn't look like a plain B3 equity/FII
/// code (free text like "Tesouro Selic 2029" or "CDB Banco X", crypto
/// symbols, BDRs, ETFs/units with ambiguous suffixes) — those types are
/// never second-guessed by this heuristic.
class TickerTypeClassifier {
  TickerTypeClassifier._();

  static final RegExp _b3Ticker = RegExp(r'^[A-Z]{4}(\d{1,2})$');

  /// B3 ETFs ("fundos de índice") use the same 4-letter + "11" suffix
  /// convention as FIIs, so the suffix alone can't tell them apart — e.g.
  /// `WRLD11` (Trend MSCI World ETF) looks identical in shape to `HGLG11`
  /// (a FII). This curated list of well-known ETF tickers is the only way
  /// to avoid misclassifying them as FIIs; it isn't exhaustive, so an
  /// unlisted "11" ticker still defaults to FII below, same as the
  /// backend's `detectAssetTypeFromTicker` heuristic.
  static const Set<String> _knownEtfTickers = {
    'BOVA11', 'IVVB11', 'SMAL11', 'SPXI11', 'DIVO11', 'FIND11', 'GOLD11',
    'HASH11', 'WRLD11', 'BBSD11', 'MATB11', 'ISUS11', 'PIBB11', 'XBOV11',
    'ECOO11', 'BRAX11', 'XINA11', 'ASIA11', 'EURP11', 'USTK11', 'NASD11',
    'URA11', 'ACWI11', 'IMAB11', 'FIXA11', 'B5MB11',
  };

  static InvestmentTypeEnum? classify(String rawTicker) {
    final ticker = rawTicker.trim().toUpperCase();
    final match = _b3Ticker.firstMatch(ticker);
    if (match == null) return null;
    final suffix = match.group(1)!;
    if (suffix == '11') {
      return _knownEtfTickers.contains(ticker) ? InvestmentTypeEnum.FUNDS : InvestmentTypeEnum.REAL_ESTATE;
    }
    if (suffix.length == 2) return null; // BDR (34/35), ETF (39), unit — ambiguous, don't guess
    return InvestmentTypeEnum.STOCKS;
  }
}
