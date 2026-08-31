/// The authenticated user's aggregated position in a specific asset.
///
/// This is distinct from market-wide data — it represents what the user
/// actually owns. Every field traces back to validated portfolio data,
/// nothing is estimated or fabricated.
class UserPosition {
  final double quantity;
  final double averagePrice;
  final double investedValue;
  final double currentValue;
  final double unrealizedGain;
  final double unrealizedGainPercent;
  final double portfolioWeight;

  const UserPosition({
    required this.quantity,
    required this.averagePrice,
    required this.investedValue,
    required this.currentValue,
    required this.unrealizedGain,
    required this.unrealizedGainPercent,
    required this.portfolioWeight,
  });

  factory UserPosition.fromJson(Map<String, dynamic> json) {
    return UserPosition(
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0,
      investedValue: (json['investedValue'] as num?)?.toDouble() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      unrealizedGain: (json['unrealizedGain'] as num?)?.toDouble() ?? 0,
      unrealizedGainPercent: (json['unrealizedGainPercent'] as num?)?.toDouble() ?? 0,
      portfolioWeight: (json['portfolioWeight'] as num?)?.toDouble() ?? 0,
    );
  }
}
