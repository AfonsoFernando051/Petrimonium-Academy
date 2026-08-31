import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// The card chrome wrapping a group of [SettingsSwitchTile]s — shared by
/// Settings' Notifications and Privacy sections (previously each screen
/// method redefined the same card).
class SettingsToggleCard extends StatelessWidget {
  const SettingsToggleCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: AppRadii.xl,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      // GlassCard paints its own background on the Container it wraps `child`
      // in, which would otherwise sit between these SwitchListTiles and the
      // nearest Material ancestor and hide their ink splashes.
      child: Material(type: MaterialType.transparency, child: Column(children: children)),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeTrackColor: tokens.primary.withValues(alpha: 0.5),
      activeThumbColor: tokens.primary,
      secondary: Icon(icon, color: tokens.textSecondary),
      title: Text(label, style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.normal)),
    );
  }
}
