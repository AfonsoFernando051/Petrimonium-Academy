import 'package:petrimonium/features/portfolio/data/datasources/missions_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';

class MissionsRepository {
  final MissionsRemoteDataSource remoteDataSource;

  MissionsRepository({required this.remoteDataSource});

  Future<MissionEvaluationResult> evaluate() async {
    final raw = await remoteDataSource.evaluate();
    return MissionEvaluationResult.fromJson(raw);
  }
}
