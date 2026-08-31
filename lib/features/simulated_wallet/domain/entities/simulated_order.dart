import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order_side.dart';

/// One executed simulated buy/sell — never a real order, never sent to any
/// broker/bank/exchange. Mirrors the backend's `SimulatedOrderDTO`.
class SimulatedOrder {
  final int id;
  final String ticker;
  final SimulatedOrderSide side;
  final double quantity;
  final double price;
  final double total;
  final DateTime executedAt;
  final String clientOrderId;

  const SimulatedOrder({
    required this.id,
    required this.ticker,
    required this.side,
    required this.quantity,
    required this.price,
    required this.total,
    required this.executedAt,
    required this.clientOrderId,
  });

  factory SimulatedOrder.fromJson(Map<String, dynamic> json) {
    return SimulatedOrder(
      id: json['id'] as int,
      ticker: json['ticker'] as String,
      side: SimulatedOrderSide.fromApiValue(json['side'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      executedAt: DateTime.parse(json['executedAt'] as String),
      clientOrderId: json['clientOrderId'] as String,
    );
  }
}
