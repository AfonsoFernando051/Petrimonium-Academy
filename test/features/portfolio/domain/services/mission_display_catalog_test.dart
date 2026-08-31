import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_display_catalog.dart';

void main() {
  group('MissionDisplayCatalog.forCode', () {
    test('returns the mapped title/description/icon for known codes', () {
      final info = MissionDisplayCatalog.forCode('daily_complete_lesson');

      expect(info.title, 'Aula do Dia');
      expect(info.description, 'Complete 1 aula hoje.');
      expect(info.icon, Icons.menu_book);
    });

    test('maps every documented mission code', () {
      final codes = {
        'daily_complete_lesson': 'Aula do Dia',
        'daily_complete_two_lessons': 'Dia Produtivo',
        'weekly_complete_three_lessons': 'Ritmo da Semana',
        'weekly_complete_module': 'Módulo Completo',
      };

      for (final entry in codes.entries) {
        expect(MissionDisplayCatalog.forCode(entry.key).title, entry.value);
      }
    });

    test('falls back to the raw code as title with empty description for an unknown code', () {
      final info = MissionDisplayCatalog.forCode('some_future_mission_code');

      expect(info.title, 'some_future_mission_code');
      expect(info.description, '');
      expect(info.icon, Icons.flag_outlined);
    });
  });
}
