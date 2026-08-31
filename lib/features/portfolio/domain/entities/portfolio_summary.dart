class PortfolioSummary {
  final double investedCapital;
  final double currentValue;
  final double totalGain;
  final double totalGainPercent;
  final int totalAssets;

  const PortfolioSummary({
    required this.investedCapital,
    required this.currentValue,
    required this.totalGain,
    required this.totalGainPercent,
    required this.totalAssets,
  });

  static const empty = PortfolioSummary(
    investedCapital: 0,
    currentValue: 0,
    totalGain: 0,
    totalGainPercent: 0,
    totalAssets: 0,
  );

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      investedCapital: (json['investedCapital'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      totalGain: (json['totalGain'] as num).toDouble(),
      totalGainPercent: (json['totalGainPercent'] as num).toDouble(),
      totalAssets: json['totalAssets'] as int,
    );
  }
}
