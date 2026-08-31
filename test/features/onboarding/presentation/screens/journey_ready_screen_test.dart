import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/journey_ready_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_preferences_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';

/// Minimal in-memory MascotRepository double, mirrors the one used in
/// `mascot_controller_test.dart` — only `loadProfile` matters here.
class FakeMascotRepository implements MascotRepository {
  PetProfile profileToReturn = PetProfile(name: 'Bolt', xp: 30);

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

  setUp(() async {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    fakeMascotRepository = FakeMascotRepository();
    DI.mascotRepository = fakeMascotRepository;
    DI.petPreferencesRepository = PetPreferencesRepository();
    await DI.petPreferencesRepository.saveGoal(PetGoalEnum.learnAboutInvesting);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const JourneyReadyScreen(),
    );
  }

  group('JourneyReadyScreen', () {
    testWidgets('renders the summary once loaded: goal, path, companion name/level, and progress', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Sua jornada está pronta.'), findsOneWidget);
      expect(find.text('Agora é hora de começar a evoluir.'), findsOneWidget);
      expect(find.text('Aprender a Investir'), findsNWidgets(2)); // goal label + path value share copy
      expect(find.textContaining('Bolt ·'), findsOneWidget);
      expect(find.text('+30 XP'), findsOneWidget);
    });

    testWidgets('renders the first mission reward card', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 950));

      expect(find.text('Sua primeira missão'), findsOneWidget);
      expect(find.text('Aprenda sobre juros compostos'), findsOneWidget);
      expect(find.text('+20 XP'), findsOneWidget);
    });

    testWidgets('tapping the CTA completes the tutorial and navigates to PortfolioChoiceScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Iniciar Minha Jornada'), findsOneWidget);

      await tester.tap(find.byType(GameButton), warnIfMissed: false);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(await DI.onboardingStateRepository.isTutorialCompleted(), isTrue);
      expect(find.byType(PortfolioChoiceScreen), findsOneWidget);
    });
  });
}
