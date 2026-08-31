import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Settings → Account: signed-in email + logout.
class AccountSection extends StatelessWidget {
  const AccountSection({super.key, required this.sectionLabel, required this.email, required this.onLogout});

  final Widget Function(String label) sectionLabel;
  final String? email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(Translator.translate(AppStrings.accountSectionTitle).toUpperCase()),
        GlassCard(
          backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
          borderColor: AppColors.neonPink.withValues(alpha: 0.3),
          borderRadius: AppRadii.xl,
          borderWidth: 1,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (email != null) ...[
                Row(
                  children: [
                    Icon(Icons.person_outline, color: tokens.textSecondary, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(email!, style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.normal)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(color: tokens.divider),
                const SizedBox(height: AppSpacing.sm),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: Icon(Icons.logout, color: tokens.error),
                  label: Text(
                    Translator.translate(AppStrings.logoutButton),
                    style: TextStyle(color: tokens.error, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tokens.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
