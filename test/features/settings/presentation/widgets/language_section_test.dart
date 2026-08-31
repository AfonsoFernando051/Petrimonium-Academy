import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/language_section.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({ValueChanged<String>? onLanguageSelected}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: LanguageSection(
          sectionLabel: (label) => Text(label),
          onLanguageSelected: onLanguageSelected ?? (_) {},
        ),
      ),
    );
  }

  group('LanguageSection', () {
    testWidgets('renders section label and all three language rows', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('IDIOMA'), findsOneWidget);
      expect(find.text('Português (Brasil)'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('shows a check icon only next to the currently selected language', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows the check next to English when currentLanguage is en', (tester) async {
      Translator.currentLanguage = 'en';
      await tester.pumpWidget(buildTestableWidget());

      final englishRow = find.ancestor(
        of: find.text('English'),
        matching: find.byType(InkWell),
      );
      expect(
        find.descendant(of: englishRow, matching: find.byIcon(Icons.check_circle)),
        findsOneWidget,
      );
    });

    testWidgets('invokes onLanguageSelected with the tapped language code', (tester) async {
      String? selected;
      await tester.pumpWidget(buildTestableWidget(onLanguageSelected: (code) => selected = code));

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(selected, 'en');
    });

    testWidgets('invokes onLanguageSelected with es when the Spanish row is tapped', (tester) async {
      String? selected;
      await tester.pumpWidget(buildTestableWidget(onLanguageSelected: (code) => selected = code));

      await tester.tap(find.text('Español'));
      await tester.pump();

      expect(selected, 'es');
    });
  });
}
