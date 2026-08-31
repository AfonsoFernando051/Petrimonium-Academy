import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/theme/theme_controller.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/appearance_option_card.dart';
import 'package:petrimonium/features/settings/presentation/widgets/appearance_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    ThemeController.themeModeNotifier.value = ThemeMode.system;
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AppearanceSection(sectionLabel: (label) => Text(label))),
    );
  }

  group('AppearanceSection', () {
    testWidgets('renders the section label and all three theme option cards', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('APARÊNCIA'), findsOneWidget);
      expect(find.byType(AppearanceOptionCard), findsNWidgets(3));
      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Escuro'), findsOneWidget);
      expect(find.text('Sistema'), findsOneWidget);
    });

    testWidgets('highlights the card matching the current ThemeController mode', (WidgetTester tester) async {
      ThemeController.themeModeNotifier.value = ThemeMode.dark;
      await tester.pumpWidget(buildTestableWidget());

      final cards = tester.widgetList<AppearanceOptionCard>(find.byType(AppearanceOptionCard)).toList();
      final selected = cards.where((c) => c.selected).toList();
      expect(selected, hasLength(1));
      expect(selected.first.label, 'Escuro');
    });

    testWidgets('tapping a card calls ThemeController.setThemeMode and updates the highlight', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Escuro'));
      await tester.pump();

      expect(ThemeController.currentThemeMode, ThemeMode.dark);
      final cards = tester.widgetList<AppearanceOptionCard>(find.byType(AppearanceOptionCard)).toList();
      expect(cards.firstWhere((c) => c.label == 'Escuro').selected, isTrue);
      expect(cards.firstWhere((c) => c.label == 'Sistema').selected, isFalse);
    });
  });
}
