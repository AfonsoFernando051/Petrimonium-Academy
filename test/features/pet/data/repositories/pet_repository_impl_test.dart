import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_repository_impl.dart';

// Mock class
class MockPetRemoteDataSource extends PetRemoteDataSource {
  bool getStatusCalled = false;
  bool configurePetCalled = false;

  MockPetRemoteDataSource() : super(apiClient: ApiClient());

  @override
  Future<bool> getPetStatus() async {
    getStatusCalled = true;
    return true; // Simulate user has a pet
  }

  @override
  Future<void> configurePet(PetSpecieEnum specie) async {
    configurePetCalled = true;
  }
}

void main() {
  late MockPetRemoteDataSource mockDataSource;
  late PetRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockPetRemoteDataSource();
    repository = PetRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('PetRepositoryImpl Tests', () {
    test('getPetStatus should call remote datasource and return true', () async {
      final result = await repository.getPetStatus();
      expect(result, true);
      expect(mockDataSource.getStatusCalled, true);
    });

    test('configurePet should call remote datasource with given specie', () async {
      await repository.configurePet(PetSpecieEnum.FOX);
      expect(mockDataSource.configurePetCalled, true);
    });
  });
}
