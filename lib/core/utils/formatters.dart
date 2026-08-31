/// Lightweight BRL/percent formatting — no `intl` dependency in this project,
/// so these are small hand-rolled helpers matching the "R\$ 15.200,00" style
/// used throughout the app (Portfolio, Asset Details, Financial Lab, ...).
class AppFormatters {
  const AppFormatters._();

  static String currency(double value, {bool showCents = true}) {
    final isNegative = value < 0;
    final abs = value.abs();
    final fixed = abs.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = _withThousands(parts[0]);
    final result = showCents ? '$intPart,${parts[1]}' : intPart;
    return '${isNegative ? '-' : ''}R\$ $result';
  }

  static String compactCurrency(double value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1000000) return '${sign}R\$ ${(abs / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${sign}R\$ ${(abs / 1000).toStringAsFixed(1)}K';
    return currency(value, showCents: false);
  }

  static String percent(double value, {bool showSign = true}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  /// Like [percent] but never shows a leading sign — for inputs/labels that
  /// are always non-negative (e.g. a slider-controlled rate), where a `+`
  /// would read as a delta instead of a plain value.
  static String percentPlain(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// "2,4x" style multiplier, e.g. for "the same basket costs 2.4x more".
  static String multiplier(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')}x';
  }

  static String _withThousands(String digits) {
    final buffer = StringBuffer();
    final reversed = digits.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write('.');
      buffer.write(reversed[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  static String date(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String shortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
