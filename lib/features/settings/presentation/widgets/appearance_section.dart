import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/theme_controller.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/appearance_option_card.dart';

/// Settings → Appearance: lets the user pick Light / Dark / System. Wraps
/// its own `ValueListenableBuilder` on [ThemeController.themeModeNotifier]
/// so the selected-state highlight updates immediately on tap, independent
/// of whatever else triggers a `SettingsScreen` rebuild.
class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key, required this.sectionLabel});

  /// Callback that renders this section's uppercase label the same way
  /// every other Settings section does (kept in the parent screen so the
  /// styling stays defined in exactly one place).
  final Widget Function(String label) sectionLabel;

  Future<void> _select(ThemeMode mode) => ThemeController.setThemeMode(mode);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeModeNotifier,
      builder: (context, mode, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionLabel(Translator.translate(AppStrings.appearanceSectionTitle).toUpperCase()),
            AppearanceOptionCard(
              icon: Icons.light_mode_rounded,
              label: Translator.translate(AppStrings.appearanceLightLabel),
              description: Translator.translate(AppStrings.appearanceLightDescription),
              swatchColors: const [Color(0xFFFFD97A), Color(0xFF00B4C6)],
              selected: mode == ThemeMode.light,
              onTap: () => _select(ThemeMode.light),
            ),
            const SizedBox(height: 10),
            AppearanceOptionCard(
              icon: Icons.dark_mode_rounded,
              label: Translator.translate(AppStrings.appearanceDarkLabel),
              description: Translator.translate(AppStrings.appearanceDarkDescription),
              swatchColors: const [Color(0xFF1A0B2E), Color(0xFF101835)],
              selected: mode == ThemeMode.dark,
              onTap: () => _select(ThemeMode.dark),
            ),
            const SizedBox(height: 10),
            AppearanceOptionCard(
              icon: Icons.brightness_auto_rounded,
              label: Translator.translate(AppStrings.appearanceSystemLabel),
              description: Translator.translate(AppStrings.appearanceSystemDescription),
              swatchColors: const [Color(0xFF8A2BE2), Color(0xFF00E5FF)],
              selected: mode == ThemeMode.system,
              onTap: () => _select(ThemeMode.system),
            ),
          ],
        );
      },
    );
  }
}
