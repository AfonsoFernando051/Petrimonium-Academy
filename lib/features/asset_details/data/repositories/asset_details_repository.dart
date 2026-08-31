import 'package:petrimonium/features/asset_details/data/datasources/asset_details_remote_datasource.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';

/// Repository for asset details — maps raw JSON from the datasource into
/// the domain [AssetDetails] model. The only place that knows the JSON
/// contract between backend and mobile.
class AssetDetailsRepository {
  final AssetDetailsRemoteDataSource remoteDataSource;

  AssetDetailsRepository({required this.remoteDataSource});

  Future<AssetDetails> fetchAssetDetails(String ticker) async {
    final raw = await remoteDataSource.fetchAssetDetails(ticker);
    return AssetDetails.fromJson(raw);
  }
}
