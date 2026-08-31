import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/services/academy_icon_registry.dart';

void main() {
  group('AcademyIconRegistry.resolve', () {
    test('resolves a known key to its IconData', () {
      expect(AcademyIconRegistry.resolve('savings_outlined'), Icons.savings_outlined);
      expect(AcademyIconRegistry.resolve('show_chart'), Icons.show_chart);
      expect(AcademyIconRegistry.resolve('trending_up'), Icons.trending_up);
    });

    test('unknown key falls back to Icons.help_outline instead of throwing', () {
      expect(AcademyIconRegistry.resolve('not_a_real_key'), Icons.help_outline);
      expect(AcademyIconRegistry.resolve(''), Icons.help_outline);
    });
  });

  group('AcademyIconRegistry.keyFor', () {
    test('resolves an IconData back to its registered key', () {
      expect(AcademyIconRegistry.keyFor(Icons.savings_outlined), 'savings_outlined');
      expect(AcademyIconRegistry.keyFor(Icons.trending_down), 'trending_down');
    });

    test('is the exact inverse of resolve for every registered key', () {
      const knownKeys = [
        'account_balance_outlined',
        'account_balance_wallet_outlined',
        'analytics_outlined',
        'bar_chart_outlined',
        'beach_access_outlined',
        'calculate_outlined',
        'candlestick_chart_outlined',
        'credit_card_outlined',
        'currency_bitcoin',
        'dashboard_customize_outlined',
        'explore_outlined',
        'flag_outlined',
        'gavel_outlined',
        'gpp_maybe_outlined',
        'health_and_safety_outlined',
        'insights_outlined',
        'map_outlined',
        'payments_outlined',
        'pie_chart_outline',
        'psychology_outlined',
        'public',
        'public_outlined',
        'query_stats_outlined',
        'receipt_long_outlined',
        'rocket_launch_outlined',
        'savings_outlined',
        'shield_outlined',
        'shopping_bag_outlined',
        'show_chart',
        'speed_outlined',
        'timeline_outlined',
        'trending_down',
        'trending_up',
      ];

      for (final key in knownKeys) {
        final icon = AcademyIconRegistry.resolve(key);
        expect(AcademyIconRegistry.keyFor(icon), key, reason: 'round-trip failed for "$key"');
      }
    });

    test('throws ArgumentError for an icon that is not registered', () {
      expect(() => AcademyIconRegistry.keyFor(Icons.abc), throwsArgumentError);
    });
  });
}
