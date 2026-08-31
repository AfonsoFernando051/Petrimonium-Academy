/// A single financial indicator displayed to the user, with its
/// current value and an optional educational explanation.
class AssetIndicator {
  final String id;        // e.g. "pe", "pvp", "roe", "dy"
  final String label;     // e.g. "P/E", "P/VP", "ROE", "DY 12M"
  final String? value;    // formatted display value, null = unavailable
  final double? rawValue; // raw numeric value for computation
  final String? unit;     // e.g. "%", "x", "R$"

  const AssetIndicator({
    required this.id,
    required this.label,
    this.value,
    this.rawValue,
    this.unit,
  });

  bool get isAvailable => value != null;
}
