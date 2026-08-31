import 'package:petrimonium/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';

class PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;

  PortfolioRepository({required this.remoteDataSource});

  Future<List<Holding>> fetchHoldings() async {
    final raw = await remoteDataSource.fetchHoldings();
    final lots = raw.map(InvestmentLot.fromJson).toList();
    return Holding.fromLots(lots);
  }

  Future<PortfolioSummary> fetchSummary() async {
    final raw = await remoteDataSource.fetchSummary();
    return PortfolioSummary.fromJson(raw);
  }

  Future<List<AllocationSlice>> fetchAllocation() async {
    final raw = await remoteDataSource.fetchAllocation();
    return raw.map(AllocationSlice.fromJson).toList();
  }

  Future<List<HistoryPoint>> fetchHistory(HistoryRange range) async {
    final raw = await remoteDataSource.fetchHistory(range.apiValue);
    return raw.map(HistoryPoint.fromJson).toList();
  }

  Future<DividendRadar> fetchDividendRadar() async {
    final raw = await remoteDataSource.fetchDividends();
    return DividendRadar.fromJson(raw);
  }
}
