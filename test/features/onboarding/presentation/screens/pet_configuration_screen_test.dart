import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/academy_intro_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/pet_configuration_screen.dart';

class MockPetRepository extends Mock implements PetRepository {}

class MockMascotRepository extends Mock implements MascotRepository {}

void main() {
  late MockPetRepository mockPetRepository;
  late MockMascotRepository mockMascotRepository;

  setUpAll(() {
    registerFallbackValue(PetSpecieEnum.DOG);
  });

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockPetRepository = MockPetRepository();
    DI.petRepository = mockPetRepository;
    mockMascotRepository = MockMascotRepository();
    DI.mascotRepository = mockMascotRepository;
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const PetConfigurationScreen(),
    );
  }

  group('PetConfigurationScreen', () {
    testWidgets('renders the title, subtitle, species selector and name field', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Hosts CosmicBackground, a pulsing GameButton and the breathing
      // PetHeroCapsule — all repeating AnimationControllers, so never call
      // pumpAndSettle.
      await tester.pump();

      expect(find.text('Conheça seu Companheiro'), findsOneWidget);
      expect(
        find.text('Sou o seu companheiro financeiro. Vou te ajudar a aprender sobre investimentos, manter a disciplina e comemorar cada conquista da sua jornada.'),
        findsOneWidget,
      );
      expect(find.text('Mas antes... eu preciso de um nome!'), findsOneWidget);
      expect(find.text('Como você gostaria de chamar seu companheiro?'), findsOneWidget);
      // One species entry per PetSpecieEnum value — the selector is a
      // horizontally scrollable list, so later entries need scrolling into
      // view first.
      for (final specie in PetSpecieEnum.values) {
        final label = specie.name[0].toUpperCase() + specie.name.substring(1).toLowerCase();
        final finder = find.text(label);
        await tester.ensureVisible(finder);
        await tester.pump();
        expect(finder, findsOneWidget, reason: specie.name);
      }
    });

    testWidgets('shows a required-name error when continuing without typing a name', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.text('Vamos começar!'), warnIfMissed: false);
      await tester.pump();

      expect(find.text('Escolha um nome para continuar'), findsOneWidget);
      verifyNever(() => mockPetRepository.configurePet(any()));
    });

    testWidgets('picking a name suggestion clears the error and fills the field', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.text('Vamos começar!'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Escolha um nome para continuar'), findsOneWidget);

      final boltChip = find.text('Bolt');
      await tester.ensureVisible(boltChip);
      await tester.pump();
      await tester.tap(boltChip, warnIfMissed: false);
      await tester.pump();

      expect(find.text('Escolha um nome para continuar'), findsNothing);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Bolt');
    });

    testWidgets('continuing with a valid name configures the pet and navigates to AcademyIntroScreen', (tester) async {
      when(() => mockPetRepository.configurePet(any())).thenAnswer((_) async {});
      when(() => mockMascotRepository.saveName(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Loki');
      await tester.pump();

      await tester.tap(find.text('Vamos começar!'), warnIfMissed: false);
      await tester.pump(); // loading state
      await tester.pump(); // configurePet + saveName resolve
      await tester.pump(const Duration(milliseconds: 350)); // route transition

      verify(() => mockPetRepository.configurePet(PetSpecieEnum.DOG)).called(1);
      verify(() => mockMascotRepository.saveName('Loki')).called(1);
      expect(find.byType(AcademyIntroScreen), findsOneWidget);
    });

    testWidgets('selecting a different species passes it to configurePet on continue', (tester) async {
      when(() => mockPetRepository.configurePet(any())).thenAnswer((_) async {});
      when(() => mockMascotRepository.saveName(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final catEntry = find.text('Cat');
      await tester.ensureVisible(catEntry);
      await tester.pump();
      await tester.tap(catEntry, warnIfMissed: false);
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Nino');
      await tester.pump();

      await tester.tap(find.text('Vamos começar!'), warnIfMissed: false);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      verify(() => mockPetRepository.configurePet(PetSpecieEnum.CAT)).called(1);
    });

    testWidgets('shows a friendly error snackbar when configurePet fails', (tester) async {
      when(() => mockPetRepository.configurePet(any())).thenThrow(Exception('boom'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Max');
      await tester.pump();

      await tester.tap(find.text('Vamos começar!'), warnIfMissed: false);
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Falha ao salvar o pet'), findsOneWidget);
    });
  });
}
