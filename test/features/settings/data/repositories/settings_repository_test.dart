import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:petrimonium/features/settings/data/repositories/settings_repository.dart';

class MockSettingsRemoteDataSource extends Mock implements SettingsRemoteDataSource {}

void main() {
  late MockSettingsRemoteDataSource mockDataSource;
  late SettingsRepository repository;

  setUp(() {
    mockDataSource = MockSettingsRemoteDataSource();
    repository = SettingsRepository(remoteDataSource: mockDataSource);
  });

  group('getLanguage', () {
    test('delegates directly to the data source', () async {
      when(() => mockDataSource.getLanguage()).thenAnswer((_) async => 'en');

      final result = await repository.getLanguage();

      expect(result, 'en');
      verify(() => mockDataSource.getLanguage()).called(1);
    });

    test('propagates a failure instead of swallowing it', () async {
      when(() => mockDataSource.getLanguage()).thenThrow(Exception('network error'));

      expect(() => repository.getLanguage(), throwsException);
    });
  });

  group('syncLanguage', () {
    test('calls updateLanguage on the data source', () async {
      when(() => mockDataSource.updateLanguage(any())).thenAnswer((_) async => 'es');

      await repository.syncLanguage('es');

      verify(() => mockDataSource.updateLanguage('es')).called(1);
    });

    test('swallows a failure instead of throwing — the local preference stays authoritative', () async {
      when(() => mockDataSource.updateLanguage(any())).thenThrow(Exception('backend unreachable'));

      // Should complete normally, not throw.
      await repository.syncLanguage('pt');
    });
  });
}
