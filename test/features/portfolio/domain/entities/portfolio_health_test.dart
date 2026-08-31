import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_health.dart';

PortfolioHealth _healthWith(double score) => PortfolioHealth(overallScore: score, metrics: const []);

void main() {
  group('PortfolioHealth.grade', () {
    test('90 and above is S', () {
      expect(_healthWith(90).grade, 'S');
      expect(_healthWith(100).grade, 'S');
    });

    test('75 up to (not including) 90 is A', () {
      expect(_healthWith(75).grade, 'A');
      expect(_healthWith(89.9).grade, 'A');
    });

    test('60 up to (not including) 75 is B', () {
      expect(_healthWith(60).grade, 'B');
      expect(_healthWith(74.9).grade, 'B');
    });

    test('40 up to (not including) 60 is C', () {
      expect(_healthWith(40).grade, 'C');
      expect(_healthWith(59.9).grade, 'C');
    });

    test('below 40 is D', () {
      expect(_healthWith(39.9).grade, 'D');
      expect(_healthWith(0).grade, 'D');
    });
  });

  group('PortfolioHealth.tier', () {
    test('75 and above is strong', () {
      expect(_healthWith(75).tier, HealthTier.strong);
      expect(_healthWith(100).tier, HealthTier.strong);
    });

    test('50 up to (not including) 75 is moderate', () {
      expect(_healthWith(50).tier, HealthTier.moderate);
      expect(_healthWith(74.9).tier, HealthTier.moderate);
    });

    test('below 50 is weak', () {
      expect(_healthWith(49.9).tier, HealthTier.weak);
      expect(_healthWith(0).tier, HealthTier.weak);
    });
  });

  group('HealthMetric.tier', () {
    HealthMetric metricWith(double score) => HealthMetric(name: 'x', score: score, icon: Icons.hub);

    test('75 and above is strong', () {
      expect(metricWith(75).tier, HealthTier.strong);
    });

    test('45 up to (not including) 75 is moderate — a lower floor than the overall score', () {
      expect(metricWith(45).tier, HealthTier.moderate);
      expect(metricWith(74.9).tier, HealthTier.moderate);
    });

    test('below 45 is weak', () {
      expect(metricWith(44.9).tier, HealthTier.weak);
    });
  });
}
