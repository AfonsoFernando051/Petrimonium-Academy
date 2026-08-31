import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';

void main() {
  group('School', () {
    test('constructs with the given fields', () {
      const school = School(
        id: 'fixed_income',
        title: 'Renda Fixa',
        description: 'Learn fixed income',
        icon: Icons.savings_outlined,
        order: 2,
        prerequisites: ['investor_foundations'],
        contentAvailable: true,
      );

      expect(school.id, 'fixed_income');
      expect(school.title, 'Renda Fixa');
      expect(school.description, 'Learn fixed income');
      expect(school.icon, Icons.savings_outlined);
      expect(school.order, 2);
      expect(school.prerequisites, ['investor_foundations']);
      expect(school.contentAvailable, isTrue);
    });

    test('prerequisites defaults to empty and contentAvailable defaults to false', () {
      const school = School(
        id: 's',
        title: 't',
        description: 'd',
        icon: Icons.help_outline,
        order: 0,
      );

      expect(school.prerequisites, isEmpty);
      expect(school.contentAvailable, isFalse);
    });
  });
}
