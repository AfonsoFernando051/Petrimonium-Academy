import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/privacy_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/settings_toggle_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({bool showOnRankings = true, ValueChanged<bool>? onChanged}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PrivacySection(
          sectionLabel: (label) => Text(label),
          showOnRankings: showOnRankings,
          onShowOnRankingsChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  group('PrivacySection', () {
    testWidgets('renders the section label and the ranking-visibility switch reflecting its value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(showOnRankings: true));

      expect(find.text('PRIVACIDADE'), findsOneWidget);
      expect(find.text('Aparecer nos rankings'), findsOneWidget);
      expect(tester.widget<SettingsSwitchTile>(find.byType(SettingsSwitchTile)).value, isTrue);
    });

    testWidgets('reflects a false value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(showOnRankings: false));

      expect(tester.widget<SettingsSwitchTile>(find.byType(SettingsSwitchTile)).value, isFalse);
    });

    testWidgets('toggling the switch calls onShowOnRankingsChanged with the new value', (WidgetTester tester) async {
      bool? newValue;
      await tester.pumpWidget(buildTestableWidget(showOnRankings: true, onChanged: (v) => newValue = v));

      await tester.tap(find.text('Aparecer nos rankings'));
      await tester.pump();

      expect(newValue, isFalse);
    });
  });
}
