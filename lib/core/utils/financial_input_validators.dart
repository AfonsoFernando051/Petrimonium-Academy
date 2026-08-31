/// Validators for user-entered financial values (asset quantity, purchase
/// price). Financial input must never silently collapse to `0.0` — a
/// malformed or missing value is a validation failure, not a valid zero.
class FinancialInputValidators {
  FinancialInputValidators._();

  static String? quantity(String? value) {
    final parsed = parsePositiveDecimal(value);
    if (parsed == null) return 'Informe uma quantidade válida.';
    if (parsed <= 0) return 'A quantidade deve ser maior que zero.';
    return null;
  }

  static String? price(String? value) {
    final parsed = parsePositiveDecimal(value);
    if (parsed == null) return 'Informe um preço válido.';
    if (parsed <= 0) return 'O preço deve ser maior que zero.';
    return null;
  }

  /// Parses [value] as a decimal (accepting `,` as a decimal separator, since
  /// that's what pt-BR keyboards produce), rejecting anything that isn't a
  /// finite number: blank input, non-numeric text, `NaN`, and `Infinity`.
  /// Returns `null` — never a fallback `0.0` — when parsing fails.
  static double? parsePositiveDecimal(String? value) {
    if (value == null) return null;
    final trimmed = value.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed.isNaN || !parsed.isFinite) return null;
    return parsed;
  }
}
