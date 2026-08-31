import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/asset_details/data/repositories/asset_details_repository.dart';
import 'package:petrimonium/features/asset_details/domain/entities/applied_concept.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/asset_details/domain/services/portfolio_learning_bridge.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';

/// Manages loading and state for the Asset Details screen.
///
/// Follows the same pattern as [PortfolioController]: receives an existing
/// [Holding] for instant cached display, then enriches from the backend.
/// This means the screen opens immediately with user-known data, and
/// progressively enhances with real market data.
class AssetDetailsController extends ChangeNotifier {
  AssetDetailsController({
    required AssetDetailsRepository repository,
  }) : _repository = repository;

  final AssetDetailsRepository _repository;

  bool isLoading = true;
  String? error;
  AssetDetails? assetDetails;

  /// Which of the user's already-completed Academy lessons apply to this
  /// asset's real indicator values — the Educational Portfolio Intelligence
  /// bridge (`PortfolioLearningBridge`). Best-effort only: this reads the
  /// Academy catalog's local cache and never blocks or fails the asset
  /// details screen if the catalog was never fetched (e.g. the user has
  /// never opened the Academy tab) or the read fails for any other reason.
  List<AppliedConcept> appliedConcepts = const [];

  /// Loads asset details for the given ticker. If a [holding] is provided
  /// (user already owns the asset), it's used to show position data
  /// immediately while the enriched data loads from the backend.
  Future<void> loadAssetDetails(String ticker, {Holding? holding}) async {
    isLoading = true;
    error = null;

    // If we have a holding, create an immediate preview from it
    if (holding != null && assetDetails == null) {
      assetDetails = _previewFromHolding(ticker, holding);
      notifyListeners();
    }

    try {
      final details = await _repository.fetchAssetDetails(ticker);
      assetDetails = details;
    } catch (e) {
      error = friendlyErrorMessage(e);
      // Keep the preview if we had one — better than showing nothing
    }

    isLoading = false;
    notifyListeners();

    unawaited(_loadAppliedConcepts());
  }

  /// Loads asynchronously, after the main details render, since it's purely
  /// additive — the screen must never wait on it or fail because of it.
  Future<void> _loadAppliedConcepts() async {
    final asset = assetDetails;
    if (asset == null) return;

    try {
      final catalog = await DI.academyCatalogRepository.loadCached(Translator.currentLanguage);
      if (catalog == null) return;

      final completedLessonIds = await DI.academyProgressRepository.loadCompletedLessonIds();
      appliedConcepts = PortfolioLearningBridge.resolve(
        lessons: catalog.lessons,
        completedLessonIds: completedLessonIds,
        asset: asset,
      );
      notifyListeners();
    } catch (_) {
      // Best-effort only — the asset details screen works fine without this.
    }
  }

  /// Refreshes the asset details from the backend.
  Future<void> refresh() async {
    if (assetDetails == null) return;
    await loadAssetDetails(assetDetails!.ticker);
  }

  /// Creates a minimal AssetDetails from an existing Holding so the
  /// screen can display immediately without waiting for the backend.
  AssetDetails _previewFromHolding(String ticker, Holding holding) {
    return AssetDetails(
      ticker: ticker,
      assetType: _typeFromEnum(holding.type),
      currentPrice: holding.currentPrice,
      currency: 'BRL',
      userPosition: UserPosition(
        quantity: holding.quantity,
        averagePrice: holding.averagePrice,
        investedValue: holding.investedValue,
        currentValue: holding.currentValue,
        unrealizedGain: holding.gainValue,
        unrealizedGainPercent: holding.gainPercent,
        portfolioWeight: holding.portfolioPercent,
      ),
      dataStatus: AssetDataStatus.cached,
    );
  }

  String _typeFromEnum(dynamic type) {
    final name = type.toString().split('.').last;
    switch (name) {
      case 'REAL_ESTATE':
        return 'fii';
      case 'FUNDS':
        return 'etf';
      case 'CRYPTO':
        return 'crypto';
      default:
        return 'stock';
    }
  }
}
