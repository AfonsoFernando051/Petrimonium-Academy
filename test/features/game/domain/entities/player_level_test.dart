import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/game/domain/entities/player_level.dart';

void main() {
  group('PlayerLevel', () {
    test('progress computes the fraction of XP into the current level', () {
      const level = PlayerLevel(level: 3, xpIntoLevel: 25, xpForNextLevel: 100);

      expect(level.progress, 0.25);
    });

    test('progress is 1.0 when xpForNextLevel is 0 (avoids division by zero)', () {
      const level = PlayerLevel(level: 3, xpIntoLevel: 25, xpForNextLevel: 0);

      expect(level.progress, 1.0);
    });

    test('progress clamps to 1.0 when xpIntoLevel exceeds xpForNextLevel', () {
      const level = PlayerLevel(level: 3, xpIntoLevel: 150, xpForNextLevel: 100);

      expect(level.progress, 1.0);
    });

    test('progress clamps to 0.0 for negative xpIntoLevel', () {
      const level = PlayerLevel(level: 3, xpIntoLevel: -10, xpForNextLevel: 100);

      expect(level.progress, 0.0);
    });

    test('equality and hashCode are value-based', () {
      const a = PlayerLevel(level: 2, xpIntoLevel: 10, xpForNextLevel: 50);
      const b = PlayerLevel(level: 2, xpIntoLevel: 10, xpForNextLevel: 50);
      const c = PlayerLevel(level: 3, xpIntoLevel: 10, xpForNextLevel: 50);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a == c, isFalse);
    });
  });
}
