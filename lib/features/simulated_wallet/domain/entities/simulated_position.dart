/// A simulated holding of [ticker] within the user's fictitious wallet —
/// entirely virtual, never a real market position. Mirrors the backend's
/// `SimulatedPositionDTO` (Petrimonium-Backend, `simulated_portfolio`
/// context).
class SimulatedPosition {
  final String ticker;
  final double quantity;
  final double averagePrice;
  final double costBasis;
  final double allocationPercent;

  const SimulatedPosition({
    required this.ticker,
    required this.quantity,
    required this.averagePrice,
    required this.costBasis,
    required this.allocationPercent,
  });

  factory SimulatedPosition.fromJson(Map<String, dynamic> json) {
    return SimulatedPosition(
      ticker: json['ticker'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      averagePrice: (json['averagePrice'] as num).toDouble(),
      costBasis: (json['costBasis'] as num).toDouble(),
      allocationPercent: (json['allocationPercent'] as num).toDouble(),
    );
  }
}
