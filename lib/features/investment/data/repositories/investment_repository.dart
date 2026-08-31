import 'package:petrimonium/features/investment/data/datasources/investment_remote_datasource.dart';
import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';

class InvestmentRepository {
  final InvestmentRemoteDataSource remoteDataSource;

  InvestmentRepository({required this.remoteDataSource});

  Future<void> configureInvestments(List<AssetRegistrationModel> investments) async {
    return await remoteDataSource.configureInvestments(investments);
  }

  Future<Map<String, dynamic>?> fetchQuote(String ticker) async {
    return await remoteDataSource.fetchQuote(ticker);
  }

  Future<Map<String, dynamic>?> fetchQuoteAtDate(String ticker, String date) async {
    return await remoteDataSource.fetchQuoteAtDate(ticker, date);
  }

  Future<List<Map<String, dynamic>>> searchQuotes(String query) async {
    return await remoteDataSource.searchQuotes(query);
  }
}
