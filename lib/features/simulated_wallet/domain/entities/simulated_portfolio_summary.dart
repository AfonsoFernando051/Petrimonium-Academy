import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_position.dart';

/// The user's fictitious wallet — virtual balance plus current simulated
/// positions. Never derived from, or connected to, any real brokerage/bank/
/// exchange account. Mirrors the backend's `SimulatedPortfolioSummaryDTO`.
class SimulatedPortfolioSummary {
  final double virtualBalance;
  final double initialBalance;
  final String currency;
  final DateTime? resetAt;
  final List<SimulatedPosition> positions;

  const SimulatedPortfolioSummary({
    required this.virtualBalance,
    required this.initialBalance,
    required this.currency,
    required this.resetAt,
    required this.positions,
  });

  static const empty = SimulatedPortfolioSummary(
    virtualBalance: 0,
    initialBalance: 0,
    currency: 'BRL',
    resetAt: null,
    positions: [],
  );

  factory SimulatedPortfolioSummary.fromJson(Map<String, dynamic> json) {
    final rawPositions = json['positions'] as List<dynamic>? ?? const [];
    return SimulatedPortfolioSummary(
      virtualBalance: (json['virtualBalance'] as num).toDouble(),
      initialBalance: (json['initialBalance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'BRL',
      resetAt: json['resetAt'] == null ? null : DateTime.parse(json['resetAt'] as String),
      positions: rawPositions
          .cast<Map<String, dynamic>>()
          .map(SimulatedPosition.fromJson)
          .toList(),
    );
  }
}
