import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/fade_route.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/unavailable_badge.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/lab_simulator_catalog.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_scaffold.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Entry point for the Financial Lab (`docs/ACADEMY_ENGINE.md` §3d/§3g) —
/// simulations that teach concepts by letting the learner change variables
/// and see why the result changes, rather than a static calculator. Tiles
/// come from [LabSimulatorCatalog] — not-yet-built simulators show the same
/// `UnavailableBadge` "coming soon" pattern already used for not-yet-
/// authored Schools/Modules.
class FinancialLabHomeScreen extends StatefulWidget {
  const FinancialLabHomeScreen({
    super.key,
    required this.mascotController,
    required this.companionController,
  });

  final MascotController mascotController;
  final PetCompanionController companionController;

  @override
  State<FinancialLabHomeScreen> createState() =>
      _FinancialLabHomeScreenState();
}

class _FinancialLabHomeScreenState extends State<FinancialLabHomeScreen> {
  final PetSpeechBubbleAnchor _headerAnchor = PetSpeechBubbleAnchor();
  bool _companionNotified = false;
  late final LabCompletionController _completionController;

  @override
  void initState() {
    super.initState();
    _completionController = LabCompletionController(
      repository: DI.academyProgressRepository,
      mascotController: widget.mascotController,
      remoteDataSource: DI.labRemoteDataSource,
    );
    _completionController.load();
    // Mirrors `AcademyHomeScreen._notifyCompanionOnce` — offered once per
    // screen lifetime; the controller's own cooldown/priority rules decide
    // whether it's actually shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _companionNotified) return;
      _companionNotified = true;
      widget.companionController.enterContext(PetContext.academy);
    });
  }

  @override
  void dispose() {
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return LabScaffold(
      titleKey: AppStrings.financialLabTitle,
      companionController: widget.companionController,
      anchor: _headerAnchor,
      backgroundIntensity: BackgroundIntensity.subtle,
      children: [
        Text(
          Translator.translate(AppStrings.financialLabSubtitle),
          style: TextStyle(
            color: tokens.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        ListenableBuilder(
          listenable: _completionController,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              for (final entry in LabSimulatorCatalog.entries)
                _LabTile(
                  icon: entry.icon,
                  title: Translator.translate(entry.titleKey),
                  subtitle: entry.subtitleKey == null
                      ? null
                      : Translator.translate(entry.subtitleKey!),
                  available: entry.available,
                  completed: entry.available &&
                      _completionController.isCompleted(entry.id),
                  onTap: !entry.available
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            fadeRoute(
                              entry.build(
                                widget.mascotController,
                                widget.companionController,
                                _completionController,
                              ),
                            ),
                          );
                        },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabTile extends StatelessWidget {
  const _LabTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.available,
    this.completed = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool available;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final accent = available ? AppColors.neonCyan : tokens.textTertiary;

    return Semantics(
      button: true,
      enabled: available,
      label: available
          ? title
          : '$title. ${Translator.translate(AppStrings.labComingSoon)}',
      child: GestureDetector(
        onTap: available ? onTap : null,
        child: Opacity(
          opacity: available ? 1 : UnavailableBadge.opacity,
          child: GlassCard(
            borderColor: accent.withValues(alpha: available ? 0.3 : 0.12),
            borderRadius: 16,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: tokens.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!available)
                    const UnavailableBadge()
                  else if (completed)
                    Icon(Icons.check_circle, color: tokens.success, size: 18)
                  else
                    Icon(Icons.chevron_right, color: tokens.textTertiary, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
