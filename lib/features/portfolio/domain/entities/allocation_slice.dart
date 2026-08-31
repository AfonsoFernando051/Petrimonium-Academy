import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// One category's slice of the Asset Allocation donut, plus its distance
/// from [PortfolioHealthCalculator]'s ideal target for that category.
class AllocationSlice {
  final InvestmentTypeEnum type;
  final double currentValue;
  final double portfolioPercent;

  const AllocationSlice({
    required this.type,
    required this.currentValue,
    required this.portfolioPercent,
  });

  factory AllocationSlice.fromJson(Map<String, dynamic> json) {
    return AllocationSlice(
      type: InvestmentTypeEnum.values.byName(json['type'] as String),
      currentValue: (json['currentValue'] as num).toDouble(),
      portfolioPercent: (json['portfolioPercent'] as num).toDouble(),
    );
  }
}
