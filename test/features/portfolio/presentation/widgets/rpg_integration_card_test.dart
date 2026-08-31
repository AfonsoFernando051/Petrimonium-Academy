import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/widgets/pet_mascot_widget.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/rpg_integration_card.dart';

/// Minimal in-memory [MascotRepository] double — only [loadProfile] matters
/// for these tests; every write is a no-op sink.
class FakeMascotRepository implements MascotRepository {
  FakeMascotRepository({PetProfile? profile}) : profileToReturn = profile ?? PetProfile();

  final PetProfile profileToReturn;

  @override
  Future<PetProfile> loadProfile() async => profileToReturn;

  @override
  Future<void> saveName(String name) async {}

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}

  @override
  Future<void> saveXp(int xp) async {}

  @override
  Future<void> saveSpecie(PetSpecieEnum specie) async {}

  @override
  Future<void> saveNetWorth(double netWorth) async {}

  @override
  Future<void> saveEquippedAccessories(Map<AccessoryType, PetAccessoryId> equipped) async {}

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

void main() {
  late MascotController controller;

  setUp(() {
    controller = MascotController(repository: FakeMascotRepository());
  });

  tearDown(() => controller.dispose());

  Widget buildTestableWidget(MascotController ctrl, PortfolioStats stats, {bool showPetVisual = true, int currentStreak = 5}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: RpgIntegrationCard(
          controller: ctrl,
          stats: stats,
          currentStreak: currentStreak,
          showPetVisual: showPetVisual,
        ),
      ),
    );
  }

  group('RpgIntegrationCard', () {
    testWidgets('renders stage label, streak and diversification stats for a fresh (0 XP) profile', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(controller, PortfolioStats.empty, showPetVisual: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('EVOLUÇÃO DO COMPANHEIRO'), findsOneWidget);
      expect(find.text('Filhote'), findsOneWidget); // babyDog label
      expect(find.text('Tier 1/9'), findsOneWidget);
      expect(find.text('5 dias'), findsOneWidget);
      expect(find.text('0 categorias'), findsOneWidget);
    });

    testWidgets('does not render PetMascotWidget when showPetVisual is false', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(controller, PortfolioStats.empty, showPetVisual: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PetMascotWidget), findsNothing);
    });

    testWidgets('renders PetMascotWidget when showPetVisual is true (default)', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(controller, PortfolioStats.empty));
      // PetMascotWidget has indefinitely-repeating "breathe" animations —
      // never pumpAndSettle here.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PetMascotWidget), findsOneWidget);
    });

    testWidgets('shows "Evolução máxima" and full XP when at the highest tier', (WidgetTester tester) async {
      final repository = FakeMascotRepository(
        profile: PetProfile(stage: PetEvolutionStage.goldenFinanceDog, xp: 99999),
      );
      final maxedController = MascotController(repository: repository);
      await maxedController.loadProfile();

      await tester.pumpWidget(buildTestableWidget(maxedController, PortfolioStats.empty, showPetVisual: false, currentStreak: 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Evolução máxima'), findsOneWidget);
      expect(find.text('99999 XP'), findsOneWidget);

      maxedController.dispose();
    });

    testWidgets('reflects stats.distinctTypeCount in the diversification tile', (WidgetTester tester) async {
      final stats = PortfolioStats(
        summary: const PortfolioSummary(
          investedCapital: 1000,
          currentValue: 1200,
          totalGain: 200,
          totalGainPercent: 20,
          totalAssets: 2,
        ),
        holdings: [
          const Holding(
            ticker: 'PETR4',
            type: InvestmentTypeEnum.STOCKS,
            quantity: 1,
            averagePrice: 1,
            currentPrice: 1,
            investedValue: 1,
            currentValue: 1,
            portfolioPercent: 50,
            lots: [],
          ),
          const Holding(
            ticker: 'HGLG11',
            type: InvestmentTypeEnum.REAL_ESTATE,
            quantity: 1,
            averagePrice: 1,
            currentPrice: 1,
            investedValue: 1,
            currentValue: 1,
            portfolioPercent: 50,
            lots: [],
          ),
        ],
        allocation: const [
          AllocationSlice(type: InvestmentTypeEnum.STOCKS, currentValue: 1, portfolioPercent: 50),
        ],
      );
      await tester.pumpWidget(buildTestableWidget(controller, stats, showPetVisual: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2 categorias'), findsOneWidget);
    });
  });
}
