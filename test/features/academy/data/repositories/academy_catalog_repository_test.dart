import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}

Map<String, dynamic> _catalogJson() => {
  'domains': [
    {
      'id': 'financial_education',
      'title': 'Educação Financeira',
      'description': 'Fundamentos para cuidar do dinheiro.',
      'iconKey': 'savings_outlined',
      'order': 1,
      'schoolIds': <String>[],
    },
  ],
  'schools': <Map<String, dynamic>>[],
  'modules': <Map<String, dynamic>>[],
  'lessons': [
    {
      'id': 'money_fundamentals_what_is_money',
      'moduleId': 'money_fundamentals',
      'title': 'O que é Dinheiro?',
      'order': 1,
      'xpReward': 20,
      'steps': <Map<String, dynamic>>[],
    },
  ],
};

void main() {
  late MockApiClient mockApiClient;
  late AcademyCatalogRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApiClient = MockApiClient();
    repository = AcademyCatalogRepository(apiClient: mockApiClient);
  });

  group('fetchAndCache', () {
    test(
      'parses the response and caches its raw body under the language key',
      () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => http.Response(jsonEncode(_catalogJson()), 200),
        );

        final snapshot = await repository.fetchAndCache('pt');

        expect(snapshot.lessons.single.id, 'money_fundamentals_what_is_money');
        verify(
          () => mockApiClient.get(
            '${ApiConstants.academyCatalogEndpoint}?lang=pt',
          ),
        ).called(1);

        final cached = await repository.loadCached('pt');
        expect(cached, isNotNull);
        expect(cached!.lessons.single.id, 'money_fundamentals_what_is_money');
      },
    );

    test('throws with the backend detail on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'detail': 'Unsupported lang: fr'}), 400),
      );

      await expectLater(
        () => repository.fetchAndCache('fr'),
        throwsA(
          predicate(
            (e) =>
                e is Exception && e.toString().contains('Unsupported lang: fr'),
          ),
        ),
      );
    });

    test('never caches a failed fetch', () async {
      when(
        () => mockApiClient.get(any()),
      ).thenAnswer((_) async => http.Response('error', 500));

      await expectLater(
        () => repository.fetchAndCache('pt'),
        throwsA(isA<Exception>()),
      );

      expect(await repository.loadCached('pt'), isNull);
    });

    test(
      'keeps the last valid cache when a successful response has no domains',
      () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => http.Response(jsonEncode(_catalogJson()), 200),
        );
        await repository.fetchAndCache('pt');

        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'domains': <Map<String, dynamic>>[],
              'schools': <Map<String, dynamic>>[],
              'modules': <Map<String, dynamic>>[],
              'lessons': <Map<String, dynamic>>[],
            }),
            200,
          ),
        );

        await expectLater(
          () => repository.fetchAndCache('pt'),
          throwsA(isA<FormatException>()),
        );

        final cached = await repository.loadCached('pt');
        expect(cached?.lessons.single.id, 'money_fundamentals_what_is_money');
      },
    );
  });

  group('loadCached', () {
    test(
      'returns null when nothing was ever fetched for that language',
      () async {
        expect(await repository.loadCached('en'), isNull);
      },
    );

    test('keeps a separate cache entry per language', () async {
      when(
        () =>
            mockApiClient.get('${ApiConstants.academyCatalogEndpoint}?lang=pt'),
      ).thenAnswer((_) async => http.Response(jsonEncode(_catalogJson()), 200));

      await repository.fetchAndCache('pt');

      expect(await repository.loadCached('pt'), isNotNull);
      expect(await repository.loadCached('en'), isNull);
    });

    test(
      'returns null instead of throwing when the cached body no longer parses',
      () async {
        // e.g. a body cached under an older/broken backend contract (a field
        // the model now casts non-nullably came back null) — must degrade to
        // "no cache" so the caller falls through to a fresh fetch, not crash.
        SharedPreferences.setMockInitialValues({
          'academy_catalog_cache_pt': jsonEncode({
            'domains': <Map<String, dynamic>>[],
            'schools': [
              {
                'id': 'orphan_school',
                'title': 'Escola órfã',
                'description': '',
                'iconKey': 'savings_outlined',
                'order': 1,
                'prerequisites': <String>[],
                'contentAvailable': true,
              },
            ],
            'modules': [
              {
                'id': 'legacy_orphan_module',
                'schoolId': null,
                'title': 'Orphan',
                'description': '',
                'iconKey': 'help_outline',
                'order': 1,
                'lessonIds': <String>[],
                'prerequisites': <String>[],
                'contentAvailable': true,
              },
            ],
            'lessons': <Map<String, dynamic>>[],
          }),
        });
        repository = AcademyCatalogRepository(apiClient: mockApiClient);

        expect(await repository.loadCached('pt'), isNull);
      },
    );

    test('discards a legacy cached catalog without domains', () async {
      SharedPreferences.setMockInitialValues({
        'academy_catalog_cache_pt': jsonEncode({
          'domains': <Map<String, dynamic>>[],
          'schools': [
            {
              'id': 'orphan_school',
              'title': 'Escola órfã',
              'description': '',
              'iconKey': 'savings_outlined',
              'order': 1,
              'prerequisites': <String>[],
              'contentAvailable': true,
            },
          ],
          'modules': <Map<String, dynamic>>[],
          'lessons': <Map<String, dynamic>>[],
        }),
      });
      repository = AcademyCatalogRepository(apiClient: mockApiClient);

      expect(await repository.loadCached('pt'), isNull);
    });

    test('discards a cached catalog with modules but no available schools', () async {
      final inconsistentCatalog = _catalogJson();
      inconsistentCatalog['schools'] = [
        {
          'id': 'financial_life',
          'title': 'Vida Financeira',
          'description': '',
          'iconKey': 'savings_outlined',
          'order': 1,
          'prerequisites': <String>[],
          'contentAvailable': false,
        },
      ];
      inconsistentCatalog['modules'] = [
        {
          'id': 'money_fundamentals',
          'schoolId': 'financial_life',
          'title': 'Fundamentos do Dinheiro',
          'description': '',
          'iconKey': 'payments_outlined',
          'order': 1,
          'lessonIds': <String>[],
          'prerequisites': <String>[],
          'contentAvailable': true,
        },
      ];
      SharedPreferences.setMockInitialValues({
        'academy_catalog_cache_pt': jsonEncode(inconsistentCatalog),
      });
      repository = AcademyCatalogRepository(apiClient: mockApiClient);

      expect(await repository.loadCached('pt'), isNull);
    });
  });
}
