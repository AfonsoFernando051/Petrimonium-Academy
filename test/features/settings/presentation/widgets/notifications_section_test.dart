import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/notifications_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/settings_toggle_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({
    bool dailyMissionReminders = true,
    bool achievementAlerts = true,
    ValueChanged<bool>? onDailyMissionRemindersChanged,
    ValueChanged<bool>? onAchievementAlertsChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: NotificationsSection(
          sectionLabel: (label) => Text(label),
          dailyMissionReminders: dailyMissionReminders,
          achievementAlerts: achievementAlerts,
          onDailyMissionRemindersChanged: onDailyMissionRemindersChanged ?? (_) {},
          onAchievementAlertsChanged: onAchievementAlertsChanged ?? (_) {},
        ),
      ),
    );
  }

  group('NotificationsSection', () {
    testWidgets('renders the section label and both switch tiles reflecting their values', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(dailyMissionReminders: true, achievementAlerts: false));

      expect(find.text('NOTIFICAÇÕES'), findsOneWidget);
      expect(find.text('Lembretes de missões diárias'), findsOneWidget);
      expect(find.text('Alertas de conquistas'), findsOneWidget);

      final switches = tester.widgetList<SettingsSwitchTile>(find.byType(SettingsSwitchTile)).toList();
      expect(switches.firstWhere((s) => s.label == 'Lembretes de missões diárias').value, isTrue);
      expect(switches.firstWhere((s) => s.label == 'Alertas de conquistas').value, isFalse);
    });

    testWidgets('toggling the daily-mission-reminders switch calls its callback with the new value', (WidgetTester tester) async {
      bool? newValue;
      await tester.pumpWidget(buildTestableWidget(
        dailyMissionReminders: true,
        onDailyMissionRemindersChanged: (v) => newValue = v,
      ));

      await tester.tap(find.text('Lembretes de missões diárias'));
      await tester.pump();

      expect(newValue, isFalse);
    });

    testWidgets('toggling the achievement-alerts switch calls its callback with the new value', (WidgetTester tester) async {
      bool? newValue;
      await tester.pumpWidget(buildTestableWidget(
        achievementAlerts: false,
        onAchievementAlertsChanged: (v) => newValue = v,
      ));

      await tester.tap(find.text('Alertas de conquistas'));
      await tester.pump();

      expect(newValue, isTrue);
    });
  });
}
