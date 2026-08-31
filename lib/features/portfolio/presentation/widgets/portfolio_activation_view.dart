import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/analytics/portfolio_activation_analytics.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/unavailable_badge.dart';
import 'package:petrimonium/features/investment/presentation/screens/investment_configuration_screen.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message_catalog.dart';
import 'package:petrimonium/features/pet/presentation/companion/rive/pet_rive_companion.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

enum _ActivationStep { intro, investorStatus, connect, learn }

/// The Portfolio tab's zero-holdings experience — shown by `PortfolioScreen`
/// instead of the normal (near-empty) dashboard whenever
/// `controller.holdings.isEmpty`. Not a pushed route: this is tab content,
/// already sitting inside `DashboardScreen`'s shared `CosmicBackground`/
/// `PetCompanionHeader`/`PetSpeechBubbleOverlay` chrome, so it needs no
/// background or companion plumbing of its own.
///
/// First-time visitors walk through intro → "do you already invest?" →
/// a contextual next step. Returning visitors (tracked by
/// `OnboardingStateRepository.hasSeenPortfolioActivation`) skip straight to
/// a compact nudge — see the field's own doc comment for why this is a
/// separate flag from the onboarding portfolio-connection step.
class PortfolioActivationView extends StatefulWidget {
  const PortfolioActivationView({
    super.key,
    required this.mascotController,
    required this.onOpenAcademyTab,
  });

  final MascotController mascotController;
  final VoidCallback onOpenAcademyTab;

  @override
  State<PortfolioActivationView> createState() =>
      _PortfolioActivationViewState();
}

class _PortfolioActivationViewState extends State<PortfolioActivationView> {
  // null while the returning-visitor flag is still loading, so the first
  // frame never flashes the full intro before collapsing to the compact view.
  bool? _isReturning;
  _ActivationStep _step = _ActivationStep.intro;
  String? _petReactionKey;

  @override
  void initState() {
    super.initState();
    _loadReturningState();
  }

  Future<void> _loadReturningState() async {
    final seen = await DI.onboardingStateRepository
        .hasSeenPortfolioActivation();
    if (!seen) {
      unawaited(DI.onboardingStateRepository.markPortfolioActivationSeen());
      unawaited(
        PortfolioActivationAnalytics.log('portfolio_activation_viewed'),
      );
    } else {
      unawaited(
        PortfolioActivationAnalytics.log(
          'portfolio_activation_returning_viewed',
        ),
      );
    }
    if (mounted) setState(() => _isReturning = seen);
  }

  void _startFlow() {
    HapticFeedback.selectionClick();
    setState(() => _step = _ActivationStep.investorStatus);
  }

  void _selectStatus(bool alreadyInvests) {
    HapticFeedback.selectionClick();
    unawaited(
      PortfolioActivationAnalytics.log(
        'portfolio_investor_status_selected',
        params: {'status': alreadyInvests ? 'yes' : 'no'},
      ),
    );
    setState(() {
      _petReactionKey = PetMessageCatalog.investorStatusReaction(
        alreadyInvests: alreadyInvests,
      );
      _step = alreadyInvests ? _ActivationStep.connect : _ActivationStep.learn;
    });
  }

  void _openConfigure() {
    HapticFeedback.mediumImpact();
    unawaited(
      PortfolioActivationAnalytics.log(
        'portfolio_activation_add_asset_started',
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InvestmentConfigurationScreen()),
    );
  }

  void _openAcademy() {
    HapticFeedback.selectionClick();
    unawaited(
      PortfolioActivationAnalytics.log('portfolio_activation_academy_selected'),
    );
    widget.onOpenAcademyTab();
  }

  void _backToCompactView() {
    setState(() => _isReturning = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isReturning == null) return const SizedBox.shrink();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _isReturning!
              ? _ReturningCard(
                  mascotController: widget.mascotController,
                  onAddAsset: _openConfigure,
                  onGoAcademy: _openAcademy,
                )
              : switch (_step) {
                  _ActivationStep.intro => _IntroCard(
                    mascotController: widget.mascotController,
                    onStart: _startFlow,
                  ),
                  _ActivationStep.investorStatus => _InvestorStatusCard(
                    onSelect: _selectStatus,
                  ),
                  _ActivationStep.connect => _ConnectCard(
                    mascotController: widget.mascotController,
                    petReactionKey: _petReactionKey,
                    onAddFirstAsset: _openConfigure,
                  ),
                  _ActivationStep.learn => _LearnCard(
                    mascotController: widget.mascotController,
                    petReactionKey: _petReactionKey,
                    onStartAcademy: _openAcademy,
                    onExploreJourney: _backToCompactView,
                  ),
                },
        ),
      ),
    );
  }
}

/// Small avatar + pet-voiced line, reused across every step — same shape as
/// `ChoiceQuestionStepView`'s `_FeedbackCard` (28px, non-interactive).
class _PetLine extends StatelessWidget {
  const _PetLine({required this.mascotController, required this.textKey});

  final MascotController mascotController;
  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: PetRiveCompanion(
            controller: mascotController,
            size: 28,
            interactive: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            Translator.translate(textKey),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 13,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.mascotController, required this.onStart});

  final MascotController mascotController;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.4),
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipOval(
              child: PetRiveCompanion(
                controller: mascotController,
                size: 72,
                interactive: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Translator.translate(AppStrings.portfolioActivationIntroTitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            Translator.translate(AppStrings.portfolioActivationIntroBody),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          GameButton(
            label: Translator.translate(
              AppStrings.portfolioActivationStartButton,
            ),
            icon: Icons.arrow_forward,
            iconTrailing: true,
            colors: const [AppColors.spaceBlue, AppColors.neonCyan],
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _InvestorStatusCard extends StatelessWidget {
  const _InvestorStatusCard({required this.onSelect});

  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.4),
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Translator.translate(AppStrings.portfolioActivationStatusQuestion),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GameButton(
            label: Translator.translate(
              AppStrings.portfolioActivationStatusYes,
            ),
            icon: Icons.check_circle_outline,
            colors: const [AppColors.spaceBlue, AppColors.neonCyan],
            onPressed: () => onSelect(true),
          ),
          const SizedBox(height: 12),
          GameButton(
            label: Translator.translate(AppStrings.portfolioActivationStatusNo),
            icon: Icons.school_outlined,
            colors: const [AppColors.neonViolet, AppColors.neonPink],
            onPressed: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

class _ConnectCard extends StatelessWidget {
  const _ConnectCard({
    required this.mascotController,
    required this.petReactionKey,
    required this.onAddFirstAsset,
  });

  final MascotController mascotController;
  final String? petReactionKey;
  final VoidCallback onAddFirstAsset;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.4),
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (petReactionKey != null) ...[
            _PetLine(
              mascotController: mascotController,
              textKey: petReactionKey!,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            Translator.translate(AppStrings.portfolioActivationConnectTitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Translator.translate(AppStrings.portfolioActivationConnectBody),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          GameButton(
            label: Translator.translate(
              AppStrings.portfolioActivationAddFirstAssetButton,
            ),
            icon: Icons.add_circle_outline,
            colors: const [AppColors.spaceBlue, AppColors.neonCyan],
            onPressed: onAddFirstAsset,
          ),
          const SizedBox(height: 12),
          Semantics(
            label:
                '${Translator.translate(AppStrings.importPortfolioButton)}. '
                '${Translator.translate(AppStrings.labComingSoon)}',
            child: GameButton.custom(
              colors: const [AppColors.neonViolet, AppColors.neonPink],
              height: 56,
              onPressed: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_download_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      Translator.translate(AppStrings.importPortfolioButton),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const UnavailableBadge(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Translator.translate(AppStrings.importComingSoonBody),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnCard extends StatelessWidget {
  const _LearnCard({
    required this.mascotController,
    required this.petReactionKey,
    required this.onStartAcademy,
    required this.onExploreJourney,
  });

  final MascotController mascotController;
  final String? petReactionKey;
  final VoidCallback onStartAcademy;
  final VoidCallback onExploreJourney;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.4),
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (petReactionKey != null) ...[
            _PetLine(
              mascotController: mascotController,
              textKey: petReactionKey!,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            Translator.translate(AppStrings.portfolioActivationLearnTitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Translator.translate(AppStrings.portfolioActivationLearnBody),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          GameButton(
            label: Translator.translate(
              AppStrings.portfolioActivationStartAcademyButton,
            ),
            icon: Icons.auto_stories_outlined,
            colors: const [AppColors.neonViolet, AppColors.neonPink],
            onPressed: onStartAcademy,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onExploreJourney,
            child: Text(
              Translator.translate(
                AppStrings.portfolioActivationExploreJourneyButton,
              ),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Returning visitor with still-zero holdings — the compact §27 experience:
/// one pet-voiced line plus two direct actions, no repeated intro/question.
class _ReturningCard extends StatelessWidget {
  const _ReturningCard({
    required this.mascotController,
    required this.onAddAsset,
    required this.onGoAcademy,
  });

  final MascotController mascotController;
  final VoidCallback onAddAsset;
  final VoidCallback onGoAcademy;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PetLine(
            mascotController: mascotController,
            textKey: AppStrings.portfolioActivationReturningNudge,
          ),
          const SizedBox(height: 16),
          GameButton(
            label: Translator.translate(
              AppStrings.portfolioActivationReturningAddAsset,
            ),
            icon: Icons.add_circle_outline,
            colors: const [AppColors.spaceBlue, AppColors.neonCyan],
            onPressed: onAddAsset,
          ),
          const SizedBox(height: 10),
          GameButton(
            label: Translator.translate(
              AppStrings.portfolioActivationReturningGoAcademy,
            ),
            icon: Icons.auto_stories_outlined,
            colors: const [AppColors.neonViolet, AppColors.neonPink],
            onPressed: onGoAcademy,
          ),
        ],
      ),
    );
  }
}
