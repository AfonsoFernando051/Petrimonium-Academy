import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/asset_details/data/repositories/asset_details_repository.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/presentation/controllers/asset_details_controller.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAssetDetailsRepository extends Mock implements AssetDetailsRepository {}

class MockAcademyCatalogRepository extends Mock implements AcademyCatalogRepository {}

const _peLesson = Lesson(
  id: 'fundamental_analysis_pl_pvp',
  moduleId: 'fundamental_analysis_module',
  title: 'P/L e P/VP',
  order: 1,
  xpReward: 20,
  portfolioConcepts: ['pe'],
  steps: [ExplanationStep(title: 'x', body: 'y')],
);

const _peLessonCatalog = AcademyCatalogSnapshot(
  domains: [],
  schools: [],
  modules: [],
  lessons: [_peLesson],
);

Holding _holdingFor(InvestmentTypeEnum type) {
  final lot = InvestmentLot(
    id: 1,
    ticker: 'PETR4',
    type: type,
    quantity: 10,
    purchasePrice: 20,
    currentPrice: 25,
    purchaseDate: DateTime(2024, 1, 1),
    investedValue: 200,
    currentValue: 250,
  );
  return Holding.fromLots([lot]).first;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAssetDetailsRepository mockRepository;
  late AssetDetailsController controller;
  late MockAcademyCatalogRepository mockCatalogRepository;

  setUp(() async {
    mockRepository = MockAssetDetailsRepository();
    controller = AssetDetailsController(repository: mockRepository);

    SharedPreferences.setMockInitialValues({});
    mockCatalogRepository = MockAcademyCatalogRepository();
    when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => null);
    DI.academyCatalogRepository = mockCatalogRepository;
    DI.academyProgressRepository = AcademyProgressLocalRepository();
  });

  group('loadAssetDetails — success', () {
    test('sets isLoading true then false, and populates assetDetails from the repository', () async {
      final details = const AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', dataStatus: AssetDataStatus.fresh);
      when(() => mockRepository.fetchAssetDetails('PETR4')).thenAnswer((_) async => details);

      final future = controller.loadAssetDetails('PETR4');
      expect(controller.isLoading, isTrue);

      await future;

      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(controller.assetDetails, details);
    });

    test('notifies listeners on completion', () async {
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) async => const AssetDetails(ticker: 'PETR4'),
      );
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.loadAssetDetails('PETR4');

      expect(notifications, greaterThan(0));
    });
  });

  group('loadAssetDetails — with a Holding (instant preview)', () {
    test('shows an immediate cached preview built from the Holding before the fetch resolves', () async {
      final holding = _holdingFor(InvestmentTypeEnum.STOCKS);
      // Never resolves during this test — asserts on the synchronous preview state.
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) => Completer<AssetDetails>().future,
      );

      final future = controller.loadAssetDetails('PETR4', holding: holding);

      // The preview is built synchronously inside loadAssetDetails, before
      // the repository call is awaited.
      expect(controller.assetDetails, isNotNull);
      expect(controller.assetDetails!.dataStatus, AssetDataStatus.cached);
      expect(controller.assetDetails!.userPosition, isNotNull);
      expect(controller.assetDetails!.userPosition!.quantity, holding.quantity);
      expect(controller.assetDetails!.currentPrice, holding.currentPrice);

      // Let the pending future settle so it doesn't leak into the next test.
      unawaited(future);
    });

    test('maps REAL_ESTATE holdings to the "fii" asset type', () async {
      final holding = _holdingFor(InvestmentTypeEnum.REAL_ESTATE);
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) => Completer<AssetDetails>().future,
      );

      final future = controller.loadAssetDetails('PETR4', holding: holding);
      expect(controller.assetDetails!.assetType, 'fii');
      unawaited(future);
    });

    test('maps FUNDS holdings to the "etf" asset type', () async {
      final holding = _holdingFor(InvestmentTypeEnum.FUNDS);
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) => Completer<AssetDetails>().future,
      );

      final future = controller.loadAssetDetails('PETR4', holding: holding);
      expect(controller.assetDetails!.assetType, 'etf');
      unawaited(future);
    });

    test('maps CRYPTO holdings to the "crypto" asset type', () async {
      final holding = _holdingFor(InvestmentTypeEnum.CRYPTO);
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) => Completer<AssetDetails>().future,
      );
      final future = controller.loadAssetDetails('PETR4', holding: holding);
      expect(controller.assetDetails!.assetType, 'crypto');
      unawaited(future);
    });

    test('maps any other type (e.g. STOCKS) to "stock"', () async {
      final holding = _holdingFor(InvestmentTypeEnum.STOCKS);
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) => Completer<AssetDetails>().future,
      );
      final future = controller.loadAssetDetails('PETR4', holding: holding);
      expect(controller.assetDetails!.assetType, 'stock');
      unawaited(future);
    });

    test('does not overwrite an already-loaded assetDetails with a fresh preview on a later call', () async {
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) async => const AssetDetails(ticker: 'PETR4', shortName: 'Real data'),
      );
      await controller.loadAssetDetails('PETR4');
      expect(controller.assetDetails!.shortName, 'Real data');

      // A second call with a holding should not clobber the already-loaded
      // real data with a synthetic preview (the `assetDetails == null` guard).
      final holding = _holdingFor(InvestmentTypeEnum.STOCKS);
      await controller.loadAssetDetails('PETR4', holding: holding);
      expect(controller.assetDetails!.shortName, 'Real data');
    });
  });

  group('loadAssetDetails — failure', () {
    test('sets error, stops loading, and keeps a prior preview instead of clearing it', () async {
      final holding = _holdingFor(InvestmentTypeEnum.STOCKS);
      final error = Exception('network down');
      when(() => mockRepository.fetchAssetDetails(any())).thenThrow(error);

      await controller.loadAssetDetails('PETR4', holding: holding);

      expect(controller.isLoading, isFalse);
      // The raw exception is never shown to the user — it's translated into
      // friendly copy via friendlyErrorMessage (see friendlyErrorMessage.dart).
      expect(controller.error, friendlyErrorMessage(error));
      // The cached preview from the holding survives the failed fetch.
      expect(controller.assetDetails, isNotNull);
      expect(controller.assetDetails!.dataStatus, AssetDataStatus.cached);
    });
  });

  group('loadAssetDetails — applied concepts (Educational Portfolio Intelligence)', () {
    test('stays empty when the Academy catalog was never cached (e.g. user never opened Academy)', () async {
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) async => const AssetDetails(ticker: 'PETR4', priceToEarnings: 8.5),
      );

      await controller.loadAssetDetails('PETR4');
      await pumpEventQueue();

      expect(controller.appliedConcepts, isEmpty);
    });

    test('stays empty when no relevant lesson has been completed', () async {
      when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => _peLessonCatalog);
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) async => const AssetDetails(ticker: 'PETR4', priceToEarnings: 8.5),
      );

      await controller.loadAssetDetails('PETR4');
      await pumpEventQueue();

      expect(controller.appliedConcepts, isEmpty);
    });

    test('populates once the relevant lesson is completed and the asset has a real value, and notifies', () async {
      when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => _peLessonCatalog);
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) async => const AssetDetails(ticker: 'PETR4', priceToEarnings: 8.5),
      );
      await DI.academyProgressRepository.markLessonCompleted('fundamental_analysis_pl_pvp');

      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.loadAssetDetails('PETR4');
      await pumpEventQueue();

      expect(controller.appliedConcepts, hasLength(1));
      expect(controller.appliedConcepts.single.indicator.id, 'pe');
      expect(controller.appliedConcepts.single.lessonId, 'fundamental_analysis_pl_pvp');
      expect(notifications, greaterThan(1)); // once for the main load, again for applied concepts
    });

    test('never throws or breaks the main load when the catalog read fails', () async {
      when(() => mockCatalogRepository.loadCached(any())).thenThrow(Exception('cache corrupted'));
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer(
        (_) async => const AssetDetails(ticker: 'PETR4', priceToEarnings: 8.5),
      );

      await controller.loadAssetDetails('PETR4');
      await pumpEventQueue();

      expect(controller.error, isNull);
      expect(controller.assetDetails, isNotNull);
      expect(controller.appliedConcepts, isEmpty);
    });
  });

  group('refresh', () {
    test('does nothing if no asset has been loaded yet', () async {
      await controller.refresh();
      verifyNever(() => mockRepository.fetchAssetDetails(any()));
    });

    test('re-fetches using the ticker of the currently loaded asset', () async {
      when(() => mockRepository.fetchAssetDetails('PETR4')).thenAnswer(
        (_) async => const AssetDetails(ticker: 'PETR4'),
      );
      await controller.loadAssetDetails('PETR4');

      await controller.refresh();

      verify(() => mockRepository.fetchAssetDetails('PETR4')).called(2);
    });
  });
}
