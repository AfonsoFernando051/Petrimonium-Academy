/// Mirrors the backend's `SimulatedOrderSide` enum exactly — the JSON wire
/// value (`name`) must match `BUY`/`SELL` case-for-case.
enum SimulatedOrderSide {
  buy,
  sell;

  String get apiValue => switch (this) {
        SimulatedOrderSide.buy => 'BUY',
        SimulatedOrderSide.sell => 'SELL',
      };

  static SimulatedOrderSide fromApiValue(String value) => switch (value) {
        'BUY' => SimulatedOrderSide.buy,
        'SELL' => SimulatedOrderSide.sell,
        _ => throw ArgumentError('Unknown SimulatedOrderSide: $value'),
      };
}
