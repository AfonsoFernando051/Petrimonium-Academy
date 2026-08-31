import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/theme/theme_controller.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/settings/data/repositories/settings_repository.dart';
import 'package:petrimonium/features/settings/presentation/screens/settings_screen.dart';
import 'package:petrimonium/features/settings/presentation/widgets/account_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/appearance_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/companion_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/language_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/notifications_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/privacy_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockMascotRepository extends Mock implements MascotRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockMascotRepository mockMascotRepository;
  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    ThemeController.themeModeNotifier.value = ThemeMode.system;

    mockAuthRepository = MockAuthRepository();
    mockMascotRepository = MockMascotRepository();
    mockSettingsRepository = MockSettingsRepository();

    when(() => mockAuthRepository.getSavedEmail()).thenAnswer((_) async => 'user@example.com');
    when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
    when(() => mockMascotRepository.loadProfile()).thenAnswer((_) async => PetProfile(name: 'Rex'));
    when(() => mockMascotRepository.saveName(any())).thenAnswer((_) async {});
    when(() => mockSettingsRepository.syncLanguage(any())).thenAnswer((_) async {});

    DI.authRepository = mockAuthRepository;
    DI.mascotRepository = mockMascotRepository;
    DI.settingsRepository = mockSettingsRepository;
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const SettingsScreen(),
    );
  }

  // The Settings body is taller than the default 800x600 test viewport, so
  // every tap below scrolls its target into view first.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  group('SettingsScreen', () {
    testWidgets('renders every section once local preferences finish loading', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // CosmicBackground has an indefinitely-repeating animation — never pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.byType(CompanionSection), findsOneWidget);
      expect(find.byType(LanguageSection), findsOneWidget);
      expect(find.byType(AppearanceSection), findsOneWidget);
      expect(find.byType(NotificationsSection), findsOneWidget);
      expect(find.byType(PrivacySection), findsOneWidget);
      expect(find.byType(AccountSection), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('Rex'), findsOneWidget);
    });

    testWidgets('toggling a notification switch persists the new value to SharedPreferences', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Lembretes de missões diárias'));
      await tester.pump(const Duration(milliseconds: 300));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('settings_daily_mission_reminders'), isFalse);
    });

    testWidgets('renaming the pet updates the shown name and persists via the mascot repository', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Renomear'));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(find.byType(TextField), 'Bolt');
      await tester.tap(find.text('Renomear').last); // the dialog's confirm action — always on-screen (centered dialog)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => mockMascotRepository.saveName('Bolt')).called(1);
      expect(find.text('Bolt'), findsOneWidget);
      expect(find.text('Nome atualizado!'), findsOneWidget);
    });

    testWidgets('cancelling the logout dialog does not call logout', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Sair'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sair do Invest Game?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verifyNever(() => mockAuthRepository.logout());
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('confirming the logout dialog logs out and navigates to LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Sair'));
      await tester.pump(const Duration(milliseconds: 300));

      // Two "Sair" widgets now exist: the section's button and the dialog's
      // confirm action — the dialog's is the more recently added, i.e. last.
      await tester.tap(find.text('Sair').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Let the push-and-remove page transition finish so the old
      // SettingsScreen route is actually disposed, not just covered.
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => mockAuthRepository.logout()).called(1);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
    });
  });
}
