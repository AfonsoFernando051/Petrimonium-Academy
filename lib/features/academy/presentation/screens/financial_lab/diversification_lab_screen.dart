import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/stat_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/domain/services/diversification_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_allocation_editor.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_comprehension_check.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_completion_footer.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_investment_type_labels.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_narrative_card.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_scaffold.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

enum _Shock { none, concentration, market }

/// The Financial Lab's Diversification simulator (`docs/DECISIONS.md`
/// DECISION-037) — an interactive portfolio composition teaching
/// concentration risk via the same HHI metric the real Portfolio tab uses,
/// plus two shock scenarios whose contrast is the actual lesson: one scales
/// with concentration, the other never does.
class DiversificationLabScreen extends StatefulWidget {
  DiversificationLabScreen({
    super.key,
    required this.mascotController,
    required this.companionController,
    required this.completionController,
    required this.onOpenWallet,
  });

  final MascotController mascotController;
  final PetCompanionController companionController;
  final LabCompletionController completionController;

  /// In-app fallback for the §1.6 Wallet bridge CTA — see WalletBridgeCta.
  final VoidCallback onOpenWallet;

  final PetSpeechBubbleAnchor _headerAnchor = PetSpeechBubbleAnchor();

  @override
  State<DiversificationLabScreen> createState() =>
      _DiversificationLabScreenState();
}

class _DiversificationLabScreenState extends State<DiversificationLabScreen> {
  Map<InvestmentTypeEnum, double> _weights = {
    InvestmentTypeEnum.STOCKS: 40,
    InvestmentTypeEnum.FIXED_INCOME: 30,
    InvestmentTypeEnum.REAL_ESTATE: 15,
    InvestmentTypeEnum.FUNDS: 10,
    InvestmentTypeEnum.CRYPTO: 5,
    InvestmentTypeEnum.OTHERS: 0,
  };
  _Shock _activeShock = _Shock.none;
  bool _canComplete = false;
  int _touchedIndex = -1;

  DiversificationResult get _result =>
      DiversificationCalculator.evaluate(_weights);

  void _onWeightChanged(InvestmentTypeEnum type, double value) {
    setState(() => _weights = {..._weights, type: value});
  }

  ChoiceQuestionStep get _comprehensionQuestion => ChoiceQuestionStep(
    framing: ChoiceStepFraming.microExercise,
    prompt: Translator.translate(AppStrings.labDiversificationQuestion),
    options: [
      Translator.translate(AppStrings.labDiversificationOptionA),
      Translator.translate(AppStrings.labDiversificationOptionB),
      Translator.translate(AppStrings.labDiversificationOptionC),
    ],
    correctIndex: 0,
    explanation: Translator.translate(
      AppStrings.labDiversificationAnswerExplanation,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return LabScaffold(
      titleKey: AppStrings.labDiversificationTitle,
      companionController: widget.companionController,
      anchor: widget._headerAnchor,
      children: [
        LabNarrativeCard(
          text: Translator.translate(AppStrings.labDiversificationIntro),
          variant: LabNarrativeVariant.introduction,
        ),
        LabAllocationEditor(
          weightsPercent: _weights,
          onChanged: _onWeightChanged,
          totalPercent: _weights.values.fold(0.0, (a, b) => a + b),
          isValid: result.isValid,
        ),
        if (result.isValid) ...[
          _buildDonutAndSummary(result),
          LabNarrativeCard(
            text: Translator.translate(
              AppStrings.labDiversificationInterpretation,
              params: {
                'category': result.largestCategory?.labLabel ?? '',
                'largestWeight': result.largestWeightPercent.round().toString(),
                'effectiveAssets': result.effectiveNumberOfAssets
                    .toStringAsFixed(1),
              },
            ),
            variant: LabNarrativeVariant.interpretation,
          ),
          _buildShockButtons(),
          if (_activeShock != _Shock.none) _buildShockResult(result),
          LabNarrativeCard(
            text: Translator.translate(
              AppStrings.labDiversificationSafetyDisclaimer,
            ),
            variant: LabNarrativeVariant.disclaimer,
          ),
          LabComprehensionCheck(
            step: _comprehensionQuestion,
            mascotController: widget.mascotController,
            onAnsweredCorrectly: () => setState(() => _canComplete = true),
          ),
          LabCompletionFooter(
            simulatorId: LabSimulatorId.diversification,
            resolvedTitle: Translator.translate(
              AppStrings.labDiversificationTitle,
            ),
            controller: widget.completionController,
            onOpenWallet: widget.onOpenWallet,
            canComplete: _canComplete && result.isValid,
          ),
        ],
      ],
    );
  }

  Widget _buildDonutAndSummary(DiversificationResult result) {
    final tokens = context.colors;
    final entries = _weights.entries.where((e) => e.value > 0).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 36,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        setState(() => _touchedIndex = -1);
                        return;
                      }
                      HapticFeedback.selectionClick();
                      setState(
                        () => _touchedIndex =
                            response.touchedSection!.touchedSectionIndex,
                      );
                    },
                  ),
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: entries[i].key.color,
                        title: '',
                        radius: i == _touchedIndex ? 24 : 18,
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 400),
              ),
              Text(
                '${result.diversificationScore.round()}',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.sm,
            children: [
              StatCard(
                label: Translator.translate(
                  AppStrings.labDiversificationEffectiveAssetsLabel,
                ),
                value: result.effectiveNumberOfAssets.toStringAsFixed(1),
                accent: AppColors.neonCyan,
              ),
              StatCard(
                label: Translator.translate(
                  AppStrings.labDiversificationConcentrationLabel,
                ),
                value:
                    '${result.largestCategory?.labLabel ?? ''} '
                    '${result.largestWeightPercent.round()}%',
                accent: _bandColor(result.band),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _bandColor(ConcentrationBand band) => switch (band) {
    ConcentrationBand.wellSpread => AppColors.positiveGreen,
    ConcentrationBand.moderate => AppColors.warningAmber,
    ConcentrationBand.concentrated => AppColors.negativeRed,
  };

  Widget _buildShockButtons() {
    return Row(
      children: [
        Expanded(
          child: GameButton(
            label: Translator.translate(
              AppStrings.labDiversificationConcentrationShockButton,
            ),
            height: 44,
            colors: const [AppColors.neonPink, AppColors.neonViolet],
            onPressed: () =>
                setState(() => _activeShock = _Shock.concentration),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: GameButton(
            label: Translator.translate(
              AppStrings.labDiversificationMarketShockButton,
            ),
            height: 44,
            colors: const [AppColors.neonCyan, AppColors.neonBlue],
            onPressed: () => setState(() => _activeShock = _Shock.market),
          ),
        ),
      ],
    );
  }

  Widget _buildShockResult(DiversificationResult result) {
    final text = _activeShock == _Shock.concentration
        ? Translator.translate(
            AppStrings.labDiversificationConcentrationShockResult,
            params: {
              'category': result.largestCategory?.labLabel ?? '',
              'impact': result.concentrationShockImpactPercent.toStringAsFixed(
                1,
              ),
            },
          )
        : Translator.translate(AppStrings.labDiversificationMarketShockResult);

    return GlassCard(
      borderColor: AppColors.neonPink.withValues(alpha: 0.3),
      borderRadius: AppRadii.lg,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          text,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
