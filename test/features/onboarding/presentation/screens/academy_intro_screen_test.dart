import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/academy_intro_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/gamification_intro_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';

class MockAcademyCatalogRepository extends Mock implements AcademyCatalogRepository {}

class MockAcademyRemoteDataSource extends Mock implements AcademyRemoteDataSource {}

const _snapshot = AcademyCatalogSnapshot(
  domains: [],
  schools: [],
  modules: [
    AcademyModule(
      id: 'm1',
      schoolId: 's1',
      title: 'Fundamentos de Investimento',
      description: 'desc',
      icon: Icons.school,
      order: 1,
      lessonIds: ['l1', 'l2', 'l3', 'l4'],
      contentAvailable: true,
    ),
    AcademyModule(
      id: 'm2',
      schoolId: 's1',
      title: 'Renda Fixa',
      description: 'desc',
      icon: Icons.savings,
      order: 2,
      lessonIds: ['l5', 'l6', 'l7'],
      prerequisites: ['m1'],
      contentAvailable: true,
    ),
  ],
  lessons: [],
);

void main() {
  late MockAcademyCatalogRepository mockCatalogRepository;
  late MockAcademyRemoteDataSource mockRemoteDataSource;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});

    mockCatalogRepository = MockAcademyCatalogRepository();
    DI.academyCatalogRepository = mockCatalogRepository;
    when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => null);
    when(() => mockCatalogRepository.fetchAndCache(any())).thenAnswer((_) async => _snapshot);

    mockRemoteDataSource = MockAcademyRemoteDataSource();
    DI.academyRemoteDataSource = mockRemoteDataSource;
    // Best-effort background sync — keep it failing harmlessly so this
    // widget test never touches the real network.
    when(() => mockRemoteDataSource.getCompletedLessonIds()).thenThrow(Exception('offline'));
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const AcademyIntroScreen(),
    );
  }

  group('AcademyIntroScreen', () {
    testWidgets('renders the title and subtitle', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Hosts CosmicBackground + a pulsing GameButton (repeating
      // AnimationControllers) — never call pumpAndSettle.
      await tester.pump();
      await tester.pump();

      expect(find.text('Sua trilha começa aqui'), findsOneWidget);
      expect(find.text('O resto libera conforme você avança — sem pular etapas.'), findsOneWidget);
    });

    testWidgets('renders a track step for each catalog module, real lesson counts, no fabricated claims', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Fundamentos de Investimento'), findsOneWidget);
      expect(find.text('Renda Fixa'), findsOneWidget);
      // m1 has no prerequisites → available → shows the "starts now" suffix.
      expect(find.text('4 aulas · começa agora'), findsOneWidget);
      // m2 requires m1 (not completed) → locked → plain lesson count only.
      expect(find.text('3 aulas'), findsOneWidget);
    });

    testWidgets('renders the Mentor intro card naming the first module', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Vamos começar por Fundamentos de Investimento. 4 aulas — dá pra começar agora.'),
        findsOneWidget,
      );
    });

    testWidgets('omits the track while the catalog has not loaded yet', (tester) async {
      final completer = Completer<AcademyCatalogSnapshot>();
      when(() => mockCatalogRepository.fetchAndCache(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Fundamentos de Investimento'), findsNothing);

      // Resolve the pending future so it doesn't leak past the test.
      completer.complete(_snapshot);
      await tester.pump();
      await tester.pump();
    });

    testWidgets('tapping Next navigates to GamificationIntroScreen', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Próximo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(GamificationIntroScreen), findsOneWidget);
    });

    testWidgets('tapping Skip navigates to FinancialGoalScreen', (tester) async {
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
