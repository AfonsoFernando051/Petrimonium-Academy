import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// Home's opening line — "Welcome back, {name}" plus a streak badge, both
/// real: [userName] comes from the account's registered name (null while
/// unresolved, in which case a name-less greeting shows rather than
/// guessing), [streakDays] from the backend's real gamification summary
/// (`GamificationSummary.currentStreak`) — hidden entirely at 0 rather than
/// showing a meaningless "0 days".
class HomeGreetingRow extends StatelessWidget {
  const HomeGreetingRow({super.key, this.userName, this.streakDays});

  final String? userName;
  final int? streakDays;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final greeting = userName == null || userName!.isEmpty
        ? Translator.translate(AppStrings.welcomeBack)
        : Translator.translate(AppStrings.homeGreetingWithName, params: {'name': userName!});

    return Row(
      children: [
        Expanded(
          child: Text(
            greeting,
            style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        if (streakDays != null && streakDays! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.warning.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  Translator.translate(AppStrings.homeStreakDaysLabel, params: {'days': '$streakDays'}),
                  style: TextStyle(color: tokens.warning, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
