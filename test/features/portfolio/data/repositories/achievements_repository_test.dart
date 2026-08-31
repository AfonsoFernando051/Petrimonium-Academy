import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/portfolio/data/datasources/achievements_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_repository.dart';

class MockAchievementsRemoteDataSource extends Mock implements AchievementsRemoteDataSource {}

void main() {
  late MockAchievementsRemoteDataSource mockDataSource;
  late AchievementsRepository repository;

  setUp(() {
    mockDataSource = MockAchievementsRemoteDataSource();
    repository = AchievementsRepository(remoteDataSource: mockDataSource);
  });

  group('evaluate', () {
    test('maps the raw JSON into an AchievementEvaluationResult', () async {
      when(() => mockDataSource.evaluate()).thenAnswer((_) async => {
            'unlockedAt': {
              'first_investment': '2024-01-01T00:00:00.000Z',
            },
            'newlyUnlockedCodes': ['first_investment'],
            'achievementXpTotal': 50,
          });

      final result = await repository.evaluate();

      expect(result.unlockedAt['first_investment'], DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(result.newlyUnlockedCodes, {'first_investment'});
      expect(result.achievementXpTotal, 50);
    });

    test('propagates a datasource failure', () async {
      when(() => mockDataSource.evaluate()).thenThrow(Exception('backend unreachable'));

      expect(() => repository.evaluate(), throwsException);
    });
  });
}
