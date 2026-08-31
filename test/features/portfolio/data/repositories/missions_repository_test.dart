import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/portfolio/data/datasources/missions_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/repositories/missions_repository.dart';

class MockMissionsRemoteDataSource extends Mock implements MissionsRemoteDataSource {}

void main() {
  late MockMissionsRemoteDataSource mockDataSource;
  late MissionsRepository repository;

  setUp(() {
    mockDataSource = MockMissionsRemoteDataSource();
    repository = MissionsRepository(remoteDataSource: mockDataSource);
  });

  group('evaluate', () {
    test('maps the raw JSON into a MissionEvaluationResult', () async {
      when(() => mockDataSource.evaluate()).thenAnswer((_) async => {
            'missions': [
              {
                'code': 'daily_login',
                'period': 'DAILY',
                'periodKey': '2024-05-01',
                'progress': 1,
                'target': 1,
                'xpReward': 10,
                'completed': true,
              },
            ],
            'newlyCompletedCodes': ['daily_login'],
            'missionXpTotal': 10,
          });

      final result = await repository.evaluate();

      expect(result.missions.length, 1);
      expect(result.missions.single.code, 'daily_login');
      expect(result.missions.single.completed, isTrue);
      expect(result.newlyCompletedCodes, {'daily_login'});
      expect(result.missionXpTotal, 10);
    });

    test('defaults to empty missions/codes/xp when the payload omits them', () async {
      when(() => mockDataSource.evaluate()).thenAnswer((_) async => <String, dynamic>{});

      final result = await repository.evaluate();

      expect(result.missions, isEmpty);
      expect(result.newlyCompletedCodes, isEmpty);
      expect(result.missionXpTotal, 0);
    });

    test('propagates a datasource failure', () async {
      when(() => mockDataSource.evaluate()).thenThrow(Exception('backend unreachable'));

      expect(() => repository.evaluate(), throwsException);
    });
  });
}
