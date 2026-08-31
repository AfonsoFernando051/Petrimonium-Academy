import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// A forward-looking, clearly-labeled *estimate* of passive income — there is
/// no real dividend/coupon payment data source anywhere in this system yet
/// (confirmed: Brapi is a live quote-only integration, no corporate-actions
/// feed exists), so this is modeled from each asset category's assumed
/// average yield rather than fabricated as if it were confirmed history.
class PassiveIncomeEstimate {
  final double monthlyEstimate;
  final double annualEstimate;
  final Map<InvestmentTypeEnum, double> monthlyByType;

  const PassiveIncomeEstimate({
    required this.monthlyEstimate,
    required this.annualEstimate,
    required this.monthlyByType,
  });

  static const empty = PassiveIncomeEstimate(monthlyEstimate: 0, annualEstimate: 0, monthlyByType: {});
}
