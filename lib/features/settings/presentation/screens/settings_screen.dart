import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/confirm_logout_dialog.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/settings/presentation/widgets/account_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/appearance_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/companion_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/language_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/notifications_section.dart';
import 'package:petrimonium/features/settings/presentation/widgets/privacy_section.dart';

/// Settings screen — owns the persisted local prefs + account/pet state and
/// composes the per-section widgets under `presentation/widgets/`. Kept as
/// the single state owner (rather than each section managing its own prefs)
/// so there is one source of truth for what gets written to
/// `SharedPreferences`/synced to the backend.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _dailyMissionRemindersKey = 'settings_daily_mission_reminders';
  static const _achievementAlertsKey = 'settings_achievement_alerts';
  static const _showOnRankingsKey = 'settings_show_on_rankings';

  String? _email;
  String? _petName;
  bool _dailyMissionReminders = true;
  bool _achievementAlerts = true;
  bool _showOnRankings = true;
  bool _loadingPrefs = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadLocalPreferences();
  }

  Future<void> _loadLocalPreferences() async {
    try {
      final email = await DI.authRepository.getSavedEmail();
      final profile = await DI.mascotRepository.loadProfile();
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _email = email;
        _petName = profile.name;
        _dailyMissionReminders = prefs.getBool(_dailyMissionRemindersKey) ?? true;
        _achievementAlerts = prefs.getBool(_achievementAlertsKey) ?? true;
        _showOnRankings = prefs.getBool(_showOnRankingsKey) ?? true;
        _loadingPrefs = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPrefs = false;
        _loadError = friendlyErrorMessage(e);
      });
    }
  }

  Future<void> _retryLoadLocalPreferences() async {
    setState(() {
      _loadingPrefs = true;
      _loadError = null;
    });
    await _loadLocalPreferences();
  }

  Future<void> _handleRenamePet() async {
    final tokens = context.colors;
    final controller = TextEditingController(text: _petName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Translator.translate(AppStrings.renamePetDialogTitle),
          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: tokens.textPrimary),
          decoration: InputDecoration(
            hintText: Translator.translate(AppStrings.namePetHint),
            hintStyle: TextStyle(color: tokens.textTertiary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translator.translate(AppStrings.cancelButton), style: TextStyle(color: tokens.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(Translator.translate(AppStrings.renamePetButton), style: TextStyle(color: tokens.primary)),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || !mounted) return;
    try {
      await DI.mascotRepository.saveName(newName);
    } catch (e) {
      if (!mounted) return;
      GameSnack.show(context, friendlyErrorMessage(e), isError: true);
      return;
    }
    if (!mounted) return;
    setState(() => _petName = newName);
    GameSnack.show(context, Translator.translate(AppStrings.renamePetSuccess), isSuccess: true);
  }

  Future<void> _setBoolPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handleLanguageSelected(String language) async {
    if (language == Translator.currentLanguage) return;
    HapticFeedback.selectionClick();
    await Translator.setLanguage(language);
    await DI.settingsRepository.syncLanguage(language);
    if (!mounted) return;
    setState(() {});
    GameSnack.show(context, Translator.translate(AppStrings.languageUpdated), isSuccess: true);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await ConfirmLogoutDialog.show(context);

    if (confirmed && mounted) {
      HapticFeedback.mediumImpact();
      try {
        await DI.authRepository.logout();
      } catch (e) {
        if (!mounted) return;
        GameSnack.show(context, friendlyErrorMessage(e), isError: true);
        return;
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(Translator.translate(AppStrings.settingsTitle), style: TextStyle(color: tokens.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: CosmicBackground(
        intensity: BackgroundIntensity.balanced,
        child: SafeArea(
          child: _loadingPrefs
              ? const AppLoadingIndicator()
              : _loadError != null
                  ? ErrorStateView(message: _loadError!, onRetry: _retryLoadLocalPreferences)
                  : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        Translator.translate(AppStrings.settingsSubtitle),
                        style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textSecondary, fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      CompanionSection(sectionLabel: _sectionLabel, petName: _petName, onRename: _handleRenamePet),
                      const SizedBox(height: AppSpacing.xl),
                      LanguageSection(sectionLabel: _sectionLabel, onLanguageSelected: _handleLanguageSelected),
                      const SizedBox(height: AppSpacing.xl),
                      AppearanceSection(sectionLabel: _sectionLabel),
                      const SizedBox(height: AppSpacing.xl),
                      NotificationsSection(
                        sectionLabel: _sectionLabel,
                        dailyMissionReminders: _dailyMissionReminders,
                        achievementAlerts: _achievementAlerts,
                        onDailyMissionRemindersChanged: (v) {
                          setState(() => _dailyMissionReminders = v);
                          _setBoolPref(_dailyMissionRemindersKey, v);
                        },
                        onAchievementAlertsChanged: (v) {
                          setState(() => _achievementAlerts = v);
                          _setBoolPref(_achievementAlertsKey, v);
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrivacySection(
                        sectionLabel: _sectionLabel,
                        showOnRankings: _showOnRankings,
                        onShowOnRankingsChanged: (v) {
                          setState(() => _showOnRankings = v);
                          _setBoolPref(_showOnRankingsKey, v);
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AccountSection(sectionLabel: _sectionLabel, email: _email, onLogout: _confirmLogout),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: context.colors.primary.withValues(alpha: 0.8),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
