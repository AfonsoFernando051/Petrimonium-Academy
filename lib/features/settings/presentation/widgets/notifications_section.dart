import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/settings_toggle_card.dart';

/// Settings → Notifications: daily-mission and achievement-alert toggles.
class NotificationsSection extends StatelessWidget {
  const NotificationsSection({
    super.key,
    required this.sectionLabel,
    required this.dailyMissionReminders,
    required this.achievementAlerts,
    required this.onDailyMissionRemindersChanged,
    required this.onAchievementAlertsChanged,
  });

  final Widget Function(String label) sectionLabel;
  final bool dailyMissionReminders;
  final bool achievementAlerts;
  final ValueChanged<bool> onDailyMissionRemindersChanged;
  final ValueChanged<bool> onAchievementAlertsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(Translator.translate(AppStrings.notificationsSectionTitle).toUpperCase()),
        SettingsToggleCard(children: [
          SettingsSwitchTile(
            icon: Icons.notifications_active_outlined,
            label: Translator.translate(AppStrings.dailyMissionReminders),
            value: dailyMissionReminders,
            onChanged: onDailyMissionRemindersChanged,
          ),
          SettingsSwitchTile(
            icon: Icons.emoji_events_outlined,
            label: Translator.translate(AppStrings.achievementAlerts),
            value: achievementAlerts,
            onChanged: onAchievementAlertsChanged,
          ),
        ]),
      ],
    );
  }
}
