import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';

void main() {
  const achievement = Achievement(
    id: 'first_investment',
    title: 'First Investment',
    description: 'Made your first investment',
    icon: Icons.emoji_events,
    xpReward: 50,
    unlocked: false,
  );

  group('Achievement', () {
    test('constructs with the given fields', () {
      expect(achievement.id, 'first_investment');
      expect(achievement.title, 'First Investment');
      expect(achievement.description, 'Made your first investment');
      expect(achievement.icon, Icons.emoji_events);
      expect(achievement.xpReward, 50);
      expect(achievement.unlocked, isFalse);
      expect(achievement.unlockedAt, isNull);
    });

    group('copyWith', () {
      test('overrides unlocked and unlockedAt while keeping other fields', () {
        final unlockedAt = DateTime(2026, 1, 1);
        final updated = achievement.copyWith(unlocked: true, unlockedAt: unlockedAt);

        expect(updated.unlocked, isTrue);
        expect(updated.unlockedAt, unlockedAt);
        expect(updated.id, achievement.id);
        expect(updated.title, achievement.title);
        expect(updated.xpReward, achievement.xpReward);
      });

      test('with no arguments keeps unlocked/unlockedAt unchanged', () {
        final updated = achievement.copyWith();
        expect(updated.unlocked, achievement.unlocked);
        expect(updated.unlockedAt, achievement.unlockedAt);
      });
    });
  });
}
