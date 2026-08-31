import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/gamification_intro_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';

/// Minimal in-memory MascotRepository double, mirrors the one used in
/// `mascot_controller_test.dart` — only `loadProfile` matters here.
class FakeMascotRepository implements MascotRepository {
  PetProfile profileToReturn = PetProfile(name: 'Bolt');

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
  late FakeMascotRepository fakeMascotRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    fakeMascotRepository = FakeMascotRepository();
    DI.mascotRepository = fakeMascotRepository;
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const GamificationIntroScreen(),
    );
  }

  group('GamificationIntroScreen', () {
    testWidgets('renders the title, subtitle, level badge, XP bar and mission card', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Hosts CosmicBackground, a pulsing GameButton and the breathing
      // PetMascotWidget/PetHeroCapsule — all repeating AnimationControllers,
      // so never call pumpAndSettle.
      await tester.pump();
      await tester.pump();

      expect(find.text('Aprenda. Jogue. Evolua.'), findsOneWidget);
      expect(find.text('Transforme conhecimento em progresso.'), findsOneWidget);
      expect(find.text('Nível 3'), findsOneWidget);
      expect(find.text('820 / 1000 XP'), findsOneWidget);
      expect(find.text('Aprenda sobre juros compostos'), findsOneWidget);
    });

    testWidgets('tapping Next navigates to FinancialGoalScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Próximo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(FinancialGoalScreen), findsOneWidget);
    });

    testWidgets('tapping Skip also navigates to FinancialGoalScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Pular'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(FinancialGoalScreen), findsOneWidget);
    });
  });
}
