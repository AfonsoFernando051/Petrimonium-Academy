/// A reference market quote used only to price a simulated order or preview
/// a ticker search result — the same public data Wallet's real quote
/// endpoint returns, reached here via the Academy-scoped passthrough
/// (`/api/v1/simulated-portfolios/quotes/*`, since `/api/investments/*` is
/// Wallet-only). Never implies a live connection to any brokerage account.
class AssetQuote {
  final String symbol;
  final String? shortName;
  final double? regularMarketPrice;
  final String currency;

  const AssetQuote({
    required this.symbol,
    required this.shortName,
    required this.regularMarketPrice,
    required this.currency,
  });

  factory AssetQuote.fromJson(Map<String, dynamic> json) {
    return AssetQuote(
      symbol: json['symbol'] as String,
      shortName: json['shortName'] as String?,
      regularMarketPrice: (json['regularMarketPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'BRL',
    );
  }
}
