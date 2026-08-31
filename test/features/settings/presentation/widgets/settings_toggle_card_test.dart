import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/settings/presentation/widgets/settings_toggle_card.dart';

void main() {
  group('SettingsToggleCard', () {
    testWidgets('renders all children passed to it', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SettingsToggleCard(children: const [
            Text('Row One'),
            Text('Row Two'),
          ]),
        ),
      ));

      expect(find.text('Row One'), findsOneWidget);
      expect(find.text('Row Two'), findsOneWidget);
    });

    testWidgets('renders empty when no children are passed', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SettingsToggleCard(children: []),
        ),
      ));

      expect(find.byType(SettingsToggleCard), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('SettingsSwitchTile', () {
    Widget buildTile({required bool value, required ValueChanged<bool> onChanged}) {
      return MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SettingsSwitchTile(
            icon: Icons.notifications_active_outlined,
            label: 'Daily reminders',
            value: value,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('renders icon, label and switch reflecting value', (tester) async {
      await tester.pumpWidget(buildTile(value: true, onChanged: (_) {}));

      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
      expect(find.text('Daily reminders'), findsOneWidget);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('reflects a false value', (tester) async {
      await tester.pumpWidget(buildTile(value: false, onChanged: (_) {}));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('invokes onChanged with the toggled value when tapped', (tester) async {
      bool? captured;
      await tester.pumpWidget(buildTile(value: false, onChanged: (v) => captured = v));

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(captured, isTrue);
    });
  });
}
