import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late PetRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = PetRemoteDataSource(apiClient: mockApiClient);
  });

  group('configurePet', () {
    test('posts the specie name and completes on 200', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response('', 200));

      await dataSource.configurePet(PetSpecieEnum.FOX);

      verify(() => mockApiClient.post('/api/pets/configure', {'specie': 'FOX'})).called(1);
    });

    test('includes the chosen name in the request body when provided', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response('', 200));

      await dataSource.configurePet(PetSpecieEnum.FOX, name: 'Rusty');

      verify(() => mockApiClient.post('/api/pets/configure', {'specie': 'FOX', 'name': 'Rusty'})).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response('', 400));

      await expectLater(
        () => dataSource.configurePet(PetSpecieEnum.DOG),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getPetStatus', () {
    test('returns hasPet from the decoded body on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'hasPet': true}), 200),
      );

      final result = await dataSource.getPetStatus();

      expect(result, isTrue);
      verify(() => mockApiClient.get('/api/pets/status')).called(1);
    });

    test('throws rather than silently returning false on a non-200 response', () async {
      // A stale/invalid session must surface as an error so the caller can
      // route back to login instead of mistaking it for "no pet yet".
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 401));

      await expectLater(
        () => dataSource.getPetStatus(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('401'))),
      );
    });
  });

  group('getMyPet', () {
    test('returns the decoded pet JSON on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'specie': 'CAT'}), 200),
      );

      final result = await dataSource.getMyPet();

      expect(result?['specie'], 'CAT');
      verify(() => mockApiClient.get('/api/pets/my-pet')).called(1);
    });

    test('returns null (rather than throwing) on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 404));

      final result = await dataSource.getMyPet();

      expect(result, isNull);
    });
  });
}
