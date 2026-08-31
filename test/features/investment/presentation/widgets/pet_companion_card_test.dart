import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/presentation/widgets/pet_companion_card.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  late MockPetRepository mockPetRepository;

  setUp(() {
    mockPetRepository = MockPetRepository();
    when(() => mockPetRepository.getMyPet()).thenAnswer((_) async => null);
    DI.petRepository = mockPetRepository;
  });

  Widget buildTestableWidget(int assetCount) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: PetCompanionCard(assetCount: assetCount)),
    );
  }

  group('PetCompanionCard', () {
    testWidgets('shows the "get started" message and mood for 0 assets', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(0));
      // Indefinitely-repeating breathe animation — never pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Vamos começar?'), findsOneWidget);
      expect(find.text('🙂'), findsOneWidget);
    });

    testWidgets('shows the congratulatory message for exactly 1 asset', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Você começou sua jornada'), findsOneWidget);
      expect(find.text('😄'), findsOneWidget);
    });

    testWidgets('shows the trophy message for 5+ assets', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('primeiro desafio'), findsOneWidget);
      expect(find.text('🏆'), findsOneWidget);
    });

    testWidgets('updates the message when assetCount changes across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🙂'), findsOneWidget);

      await tester.pumpWidget(buildTestableWidget(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('🎉'), findsOneWidget);
      expect(find.textContaining('crescendo'), findsOneWidget);
    });

    testWidgets('honors disableAnimations — still renders, no crash', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(0),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.text('🙂'), findsOneWidget);
    });

    testWidgets('falls back to the default fox illustration when the pet repository call fails', (WidgetTester tester) async {
      when(() => mockPetRepository.getMyPet()).thenThrow(Exception('offline'));

      await tester.pumpWidget(buildTestableWidget(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Reaching here without an unhandled exception is the assertion —
      // the widget swallows the failure and keeps the fallback asset.
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
