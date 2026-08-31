import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';

class GamificationRepository {
  final GamificationRemoteDataSource remoteDataSource;

  GamificationRepository({required this.remoteDataSource});

  Future<GamificationSummary> fetchSummary() async {
    final raw = await remoteDataSource.fetchSummary();
    return GamificationSummary.fromJson(raw);
  }
}
