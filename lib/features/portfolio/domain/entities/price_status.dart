/// Where a lot's `currentPrice` came from — mirrors the backend's
/// `PriceStatus` enum (`core/domain/enums/PriceStatus.java`), serialized as
/// the `priceStatus` field of each lot in `GET /api/investments`.
///
/// Exists because falling back to the purchase price is indistinguishable
/// from a real quote that happens to equal it: both render as "0%". Without
/// this the user is told "your position hasn't moved" when the truth is
/// "we don't know what it's worth".
enum PriceStatus {
  /// A real quote from the market-data provider. Gain/loss is meaningful.
  live,

  /// The quote was unavailable and `currentPrice` fell back to the purchase
  /// price. Gain/loss is NOT meaningful and must never be shown as a return.
  stalePurchasePrice,

  /// The asset class has no quote feed at all (fixed income). Unlike
  /// [stalePurchasePrice] this will not resolve by retrying, so the UI should
  /// not offer a "try again".
  notQuoted;

  /// Parses the backend's SCREAMING_SNAKE_CASE wire value. An unknown or
  /// missing value is treated as [stalePurchasePrice] rather than [live]:
  /// if we can't tell where a price came from, we must not present it as a
  /// confirmed one.
  static PriceStatus fromWire(String? value) {
    switch (value) {
      case 'LIVE':
        return PriceStatus.live;
      case 'NOT_QUOTED':
        return PriceStatus.notQuoted;
      case 'STALE_PURCHASE_PRICE':
        return PriceStatus.stalePurchasePrice;
      default:
        return PriceStatus.stalePurchasePrice;
    }
  }

  /// Whether a gain/loss figure derived from this price can honestly be
  /// shown as a return.
  bool get isLive => this == PriceStatus.live;
}
