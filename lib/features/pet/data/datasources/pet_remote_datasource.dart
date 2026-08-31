import 'dart:convert';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';

class PetRemoteDataSource {
  final ApiClient apiClient;

  PetRemoteDataSource({required this.apiClient});

  Future<void> configurePet(PetSpecieEnum specie) async {
    final response = await apiClient.post(
      '/api/pets/configure',
      {'specie': specie.name},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to configure pet');
    }
  }

  Future<bool> getPetStatus() async {
    final response = await apiClient.get('/api/pets/status');
    if (response.statusCode != 200) {
      // A non-200 here means the request was rejected before reaching the
      // controller (e.g. a token whose signature still checks out locally
      // but whose user no longer exists server-side — trivially reproducible
      // in dev, since the backend's H2 database is in-memory and resets on
      // every restart while the mobile client's stored JWT survives it).
      // Swallowing this into `false` used to be indistinguishable from a
      // real "logged in, no pet yet" user, sending a stale/invalid session
      // straight to pet setup instead of back to login — see `MyApp._getStartRoute`.
      throw Exception('Failed to load pet status (${response.statusCode})');
    }
    final data = jsonDecode(response.body);
    return data['hasPet'] as bool;
  }

  Future<Map<String, dynamic>?> getMyPet() async {
    final response = await apiClient.get('/api/pets/my-pet');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}
