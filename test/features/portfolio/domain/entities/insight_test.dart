import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/insight.dart';
import 'package:petrimonium/features/portfolio/domain/enums/insight_priority.dart';

void main() {
  group('Insight', () {
    test('holds all provided fields, optional actionLabel/onAction default to null', () {
      const insight = Insight(
        title: 'Diversifique',
        description: 'Sua carteira está concentrada em um único ativo.',
        icon: Icons.warning,
        priority: InsightPriority.high,
        color: Colors.red,
      );

      expect(insight.title, 'Diversifique');
      expect(insight.description, 'Sua carteira está concentrada em um único ativo.');
      expect(insight.icon, Icons.warning);
      expect(insight.priority, InsightPriority.high);
      expect(insight.color, Colors.red);
      expect(insight.actionLabel, isNull);
      expect(insight.onAction, isNull);
    });

    test('carries optional actionLabel and onAction callback when provided', () {
      var tapped = false;
      final insight = Insight(
        title: 'Complete seu perfil',
        description: 'Adicione mais ativos.',
        icon: Icons.info,
        priority: InsightPriority.low,
        color: Colors.blue,
        actionLabel: 'Adicionar',
        onAction: () => tapped = true,
      );

      expect(insight.actionLabel, 'Adicionar');
      insight.onAction!();
      expect(tapped, isTrue);
    });
  });
}
