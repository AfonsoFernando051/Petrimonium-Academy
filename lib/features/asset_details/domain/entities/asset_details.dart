import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';

/// Comprehensive asset details model — the normalized representation of
/// everything the app knows about a single asset, combining provider market
/// data with the user's personal position.
///
/// Every field except [ticker] is nullable. The UI must handle absent data
/// gracefully ("Data unavailable") rather than expecting every field to be
/// present. **No field is ever fabricated.**
class AssetDetails {
  // ── Identity ──────────────────────────────────────────────────────
  final String ticker;
  final String? shortName;
  final String? longName;
  final String assetType; // "stock", "fii", "etf", "bdr", "unknown"
  final String? sector;
  final String? industry;
  final String? logoUrl;

  // ── Price ─────────────────────────────────────────────────────────
  final double? currentPrice;
  final double? previousClose;
  final double? dailyChange;
  final double? dailyChangePercent;
  final String? currency;

  // ── Valuation ─────────────────────────────────────────────────────
  final double? marketCap;
  final double? priceToEarnings;  // P/E (P/L)
  final double? priceToBook;     // P/VP
  final double? evToEbitda;
  final double? dividendYield;

  // ── Profitability ─────────────────────────────────────────────────
  final double? returnOnEquity;  // ROE
  final double? returnOnAssets;  // ROA
  final double? netMargin;
  final double? operatingMargin;

  // ── Financial health ──────────────────────────────────────────────
  final double? netDebt;
  final double? debtToEquity;
  final double? totalCash;
  final double? totalRevenue;
  final double? ebitda;

  // ── FII-specific ──────────────────────────────────────────────────
  final double? netAssetValue;
  final double? pvp;

  // ── 52-week range ─────────────────────────────────────────────────
  final double? fiftyTwoWeekHigh;
  final double? fiftyTwoWeekLow;

  // ── Volume ────────────────────────────────────────────────────────
  final int? averageVolume;
  final int? regularMarketVolume;

  // ── User position ─────────────────────────────────────────────────
  final UserPosition? userPosition;

  // ── Dividends ─────────────────────────────────────────────────────
  final List<DividendEvent> recentDividends;

  // ── Meta ───────────────────────────────────────────────────────────
  final String? dataSource;
  final String? lastUpdated;
  final AssetDataStatus dataStatus;

  const AssetDetails({
    required this.ticker,
    this.shortName,
    this.longName,
    this.assetType = 'unknown',
    this.sector,
    this.industry,
    this.logoUrl,
    this.currentPrice,
    this.previousClose,
    this.dailyChange,
    this.dailyChangePercent,
    this.currency,
    this.marketCap,
    this.priceToEarnings,
    this.priceToBook,
    this.evToEbitda,
    this.dividendYield,
    this.returnOnEquity,
    this.returnOnAssets,
    this.netMargin,
    this.operatingMargin,
    this.netDebt,
    this.debtToEquity,
    this.totalCash,
    this.totalRevenue,
    this.ebitda,
    this.netAssetValue,
    this.pvp,
    this.fiftyTwoWeekHigh,
    this.fiftyTwoWeekLow,
    this.averageVolume,
    this.regularMarketVolume,
    this.userPosition,
    this.recentDividends = const [],
    this.dataSource,
    this.lastUpdated,
    this.dataStatus = AssetDataStatus.unavailable,
  });

  /// The display name — prefers shortName, falls back to ticker.
  String get displayName => shortName ?? ticker;

  /// Whether the user currently owns this asset.
  bool get isOwned => userPosition != null && userPosition!.quantity > 0;

  /// Whether this is a stock (ações).
  bool get isStock => assetType == 'stock';

  /// Whether this is a FII (fundo imobiliário).
  bool get isFii => assetType == 'fii';

  /// Whether this is an ETF.
  bool get isEtf => assetType == 'etf';

  /// Whether this is a BDR.
  bool get isBdr => assetType == 'bdr';

  /// Upcoming (announced but not yet paid) dividends.
  List<DividendEvent> get upcomingDividends =>
      recentDividends.where((d) => d.status == DividendStatus.ANNOUNCED).toList();

  /// Historical (already paid) dividends, most recent first.
  List<DividendEvent> get paidDividends =>
      recentDividends.where((d) => d.status == DividendStatus.PAID).toList();

  factory AssetDetails.fromJson(Map<String, dynamic> json) {
    return AssetDetails(
      ticker: json['ticker'] as String? ?? '',
      shortName: json['shortName'] as String?,
      longName: json['longName'] as String?,
      assetType: json['assetType'] as String? ?? 'unknown',
      sector: json['sector'] as String?,
      industry: json['industry'] as String?,
      logoUrl: json['logoUrl'] as String?,
      currentPrice: (json['currentPrice'] as num?)?.toDouble(),
      previousClose: (json['previousClose'] as num?)?.toDouble(),
      dailyChange: (json['dailyChange'] as num?)?.toDouble(),
      dailyChangePercent: (json['dailyChangePercent'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      marketCap: (json['marketCap'] as num?)?.toDouble(),
      priceToEarnings: (json['priceToEarnings'] as num?)?.toDouble(),
      priceToBook: (json['priceToBook'] as num?)?.toDouble(),
      evToEbitda: (json['evToEbitda'] as num?)?.toDouble(),
      dividendYield: (json['dividendYield'] as num?)?.toDouble(),
      returnOnEquity: (json['returnOnEquity'] as num?)?.toDouble(),
      returnOnAssets: (json['returnOnAssets'] as num?)?.toDouble(),
      netMargin: (json['netMargin'] as num?)?.toDouble(),
      operatingMargin: (json['operatingMargin'] as num?)?.toDouble(),
      netDebt: (json['netDebt'] as num?)?.toDouble(),
      debtToEquity: (json['debtToEquity'] as num?)?.toDouble(),
      totalCash: (json['totalCash'] as num?)?.toDouble(),
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
      ebitda: (json['ebitda'] as num?)?.toDouble(),
      netAssetValue: (json['netAssetValue'] as num?)?.toDouble(),
      pvp: (json['pvp'] as num?)?.toDouble(),
      fiftyTwoWeekHigh: (json['fiftyTwoWeekHigh'] as num?)?.toDouble(),
      fiftyTwoWeekLow: (json['fiftyTwoWeekLow'] as num?)?.toDouble(),
      averageVolume: (json['averageVolume'] as num?)?.toInt(),
      regularMarketVolume: (json['regularMarketVolume'] as num?)?.toInt(),
      userPosition: json['userPosition'] != null
          ? UserPosition.fromJson(json['userPosition'] as Map<String, dynamic>)
          : null,
      recentDividends: (json['recentDividends'] as List<dynamic>?)
              ?.map((e) => DividendEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dataSource: json['dataSource'] as String?,
      lastUpdated: json['lastUpdated'] as String?,
      dataStatus: AssetDataStatus.fromString(json['dataStatus'] as String?),
    );
  }
}
