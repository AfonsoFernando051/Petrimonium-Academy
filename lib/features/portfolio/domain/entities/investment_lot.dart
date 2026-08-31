import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// One purchase lot exactly as persisted on the backend — a single row in
/// `jf_investments`. A [Holding] aggregates one or more lots that share the
/// same ticker (a user may have bought the same asset on different dates).
class InvestmentLot {
  final int id;
  final String ticker;
  final InvestmentTypeEnum type;
  final double quantity;
  final double purchasePrice;
  final DateTime purchaseDate;
  final double currentPrice;
  final double investedValue;
  final double currentValue;

  const InvestmentLot({
    required this.id,
    required this.ticker,
    required this.type,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.currentPrice,
    required this.investedValue,
    required this.currentValue,
  });

  double get gainValue => currentValue - investedValue;

  double get gainPercent => investedValue == 0 ? 0.0 : (gainValue / investedValue) * 100;

  factory InvestmentLot.fromJson(Map<String, dynamic> json) {
    final quantity = (json['quantity'] as num).toDouble();
    final purchasePrice = (json['purchasePrice'] as num).toDouble();
    final currentPrice = (json['currentPrice'] as num?)?.toDouble() ?? purchasePrice;
    return InvestmentLot(
      id: json['id'] as int,
      ticker: json['name'] as String,
      type: InvestmentTypeEnum.values.byName(json['type'] as String),
      quantity: quantity,
      purchasePrice: purchasePrice,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      currentPrice: currentPrice,
      investedValue: (json['investedValue'] as num?)?.toDouble() ?? quantity * purchasePrice,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? quantity * currentPrice,
    );
  }
}
