import 'package:petrimonium/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> configurePet(PetSpecieEnum specie, {String? name}) async {
    return await remoteDataSource.configurePet(specie, name: name);
  }

  @override
  Future<bool> getPetStatus() async {
    return await remoteDataSource.getPetStatus();
  }

  @override
  Future<Map<String, dynamic>?> getMyPet() async {
    return await remoteDataSource.getMyPet();
  }
}
