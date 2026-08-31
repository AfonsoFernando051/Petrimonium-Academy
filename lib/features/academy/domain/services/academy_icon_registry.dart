import 'package:flutter/material.dart';

/// String key ↔ [IconData] for every icon the Academy curriculum uses.
///
/// `IconData` is a compile-time const resolved by the Flutter tree-shaker —
/// it can't be serialized into JSON/a database column directly. The
/// backend/JSON content instead stores the key (e.g. `"savings_outlined"`)
/// and this registry resolves it back to the actual const `Icons.xxx`
/// reference at build time, so tree-shaking still works.
///
/// This is the single source of truth for the mapping, shared by
/// `tool/generate_academy_seed_json.dart` (reverse lookup, Dart → key, for
/// the one-time content migration) and `AcademyCatalogSnapshot.fromJson`
/// (forward lookup, key → Dart, for every catalog fetch). Keep it in sync
/// with whatever icons the authored JSON content actually uses — an unknown
/// key falls back to [Icons.help_outline] rather than throwing, since a new
/// icon added to content shouldn't crash the app on an old registry.
class AcademyIconRegistry {
  const AcademyIconRegistry._();

  static const Map<String, IconData> _icons = {
    'account_balance_outlined': Icons.account_balance_outlined,
    'account_balance_wallet_outlined': Icons.account_balance_wallet_outlined,
    'analytics_outlined': Icons.analytics_outlined,
    'bar_chart_outlined': Icons.bar_chart_outlined,
    'beach_access_outlined': Icons.beach_access_outlined,
    'calculate_outlined': Icons.calculate_outlined,
    'candlestick_chart_outlined': Icons.candlestick_chart_outlined,
    'credit_card_outlined': Icons.credit_card_outlined,
    'currency_bitcoin': Icons.currency_bitcoin,
    'dashboard_customize_outlined': Icons.dashboard_customize_outlined,
    'explore_outlined': Icons.explore_outlined,
    'flag_outlined': Icons.flag_outlined,
    'gavel_outlined': Icons.gavel_outlined,
    'gpp_maybe_outlined': Icons.gpp_maybe_outlined,
    'health_and_safety_outlined': Icons.health_and_safety_outlined,
    'insights_outlined': Icons.insights_outlined,
    'map_outlined': Icons.map_outlined,
    'payments_outlined': Icons.payments_outlined,
    'pie_chart_outline': Icons.pie_chart_outline,
    'psychology_outlined': Icons.psychology_outlined,
    'public': Icons.public,
    'public_outlined': Icons.public_outlined,
    'query_stats_outlined': Icons.query_stats_outlined,
    'receipt_long_outlined': Icons.receipt_long_outlined,
    'rocket_launch_outlined': Icons.rocket_launch_outlined,
    'savings_outlined': Icons.savings_outlined,
    'shield_outlined': Icons.shield_outlined,
    'shopping_bag_outlined': Icons.shopping_bag_outlined,
    'show_chart': Icons.show_chart,
    'speed_outlined': Icons.speed_outlined,
    'timeline_outlined': Icons.timeline_outlined,
    'trending_down': Icons.trending_down,
    'trending_up': Icons.trending_up,
  };

  static IconData resolve(String key) => _icons[key] ?? Icons.help_outline;

  /// Reverse lookup (`IconData` → key), used only by the one-time content
  /// migration script (`tool/generate_academy_seed_json.dart`). Throws if
  /// [icon] isn't registered — the script is meant to fail loudly on an
  /// unmapped icon rather than silently emit a wrong key.
  static String keyFor(IconData icon) {
    for (final entry in _icons.entries) {
      if (entry.value == icon) return entry.key;
    }
    throw ArgumentError('No registry key for icon: $icon');
  }
}
