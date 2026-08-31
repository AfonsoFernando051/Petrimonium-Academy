import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/labeled_slider.dart';
import 'package:petrimonium/core/widgets/stat_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/domain/services/portfolio_scenario_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_allocation_editor.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_comprehension_check.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_completion_footer.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_narrative_card.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_scaffold.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The Financial Lab's Portfolio simulator (`docs/DECISIONS.md`
/// DECISION-037) — the most connected to the real product, but deliberately
/// an educational sandbox: a hypothetical portfolio, never the user's real
/// one, tested against fixed, named, deterministic scenarios.
class PortfolioLabScreen extends StatefulWidget {
  PortfolioLabScreen({
    super.key,
    required this.mascotController,
    required this.companionController,
    required this.completionController,
  });

  final MascotController mascotController;
  final PetCompanionController companionController;
  final LabCompletionController completionController;

  final PetSpeechBubbleAnchor _headerAnchor = PetSpeechBubbleAnchor();

  @override
  State<PortfolioLabScreen> createState() => _PortfolioLabScreenState();
}

class _PortfolioLabScreenState extends State<PortfolioLabScreen> {
  double _totalAmount = 50000;
  Map<InvestmentTypeEnum, double> _weights = {
    InvestmentTypeEnum.STOCKS: 40,
    InvestmentTypeEnum.FIXED_INCOME: 30,
    InvestmentTypeEnum.REAL_ESTATE: 15,
    InvestmentTypeEnum.FUNDS: 10,
    InvestmentTypeEnum.CRYPTO: 5,
    InvestmentTypeEnum.OTHERS: 0,
  };
  LabScenario? _scenario;
  bool _canComplete = false;

  double get _totalWeight => _weights.values.fold(0.0, (a, b) => a + b);
  bool get _isAllocationValid => (100 - _totalWeight).abs() < 0.01;

  PortfolioScenarioResult? get _result {
    final scenario = _scenario;
    if (scenario == null || !_isAllocationValid) return null;
    return PortfolioScenarioCalculator.evaluate(
      totalAmount: _totalAmount,
      weightsPercent: _weights,
      scenario: scenario,
    );
  }

  ChoiceQuestionStep get _comprehensionQuestion => ChoiceQuestionStep(
    framing: ChoiceStepFraming.apply,
    prompt: Translator.translate(AppStrings.labPortfolioQuestion),
    options: [
      Translator.translate(AppStrings.labPortfolioOptionA),
      Translator.translate(AppStrings.labPortfolioOptionB),
      Translator.translate(AppStrings.labPortfolioOptionC),
    ],
    correctIndex: 0,
    explanation: Translator.translate(AppStrings.labPortfolioAnswerExplanation),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return LabScaffold(
      titleKey: AppStrings.labPortfolioTitle,
      companionController: widget.companionController,
      anchor: widget._headerAnchor,
      children: [
        LabNarrativeCard(
          text: Translator.translate(AppStrings.labPortfolioIntro),
          variant: LabNarrativeVariant.introduction,
        ),
        LabNarrativeCard(
          text: Translator.translate(AppStrings.labPortfolioSandboxDisclaimer),
          variant: LabNarrativeVariant.disclaimer,
        ),
        _buildTotalAmountInput(),
        LabAllocationEditor(
          weightsPercent: _weights,
          onChanged: (type, value) =>
              setState(() => _weights = {..._weights, type: value}),
          totalPercent: _totalWeight,
          isValid: _isAllocationValid,
        ),
        if (_isAllocationValid) ...[
          _buildScenarioChips(),
          if (result != null) _buildScenarioResult(result),
          LabNarrativeCard(
            text: Translator.translate(
              AppStrings.labPortfolioForecastDisclaimer,
            ),
            variant: LabNarrativeVariant.disclaimer,
          ),
          LabComprehensionCheck(
            step: _comprehensionQuestion,
            mascotController: widget.mascotController,
            onAnsweredCorrectly: () => setState(() => _canComplete = true),
          ),
          LabCompletionFooter(
            simulatorId: LabSimulatorId.portfolio,
            resolvedTitle: Translator.translate(AppStrings.labPortfolioTitle),
            controller: widget.completionController,
            canComplete: _canComplete && _isAllocationValid,
          ),
        ],
      ],
    );
  }

  Widget _buildTotalAmountInput() {
    return GlassCard(
      borderRadius: AppRadii.xl,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LabeledSlider(
          label: Translator.translate(AppStrings.labPortfolioTotalAmountLabel),
          valueLabel: AppFormatters.currency(_totalAmount, showCents: false),
          value: _totalAmount,
          min: 0,
          max: 500000,
          divisions: 100,
          onChanged: (v) => setState(() => _totalAmount = v),
        ),
      ),
    );
  }

  Widget _buildScenarioChips() {
    final tokens = context.colors;
    final scenarios = {
      LabScenario.equitiesDown15: AppStrings.labPortfolioScenarioEquitiesDown15,
      LabScenario.largestPositionDown20:
          AppStrings.labPortfolioScenarioLargestPositionDown20,
      LabScenario.broadMarketDown10:
          AppStrings.labPortfolioScenarioBroadMarketDown10,
      LabScenario.fixedIncomeUp5: AppStrings.labPortfolioScenarioFixedIncomeUp5,
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entry in scenarios.entries)
          _ScenarioChip(
            label: Translator.translate(entry.value),
            selected: _scenario == entry.key,
            tokens: tokens,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _scenario = entry.key);
            },
          ),
      ],
    );
  }

  Widget _buildScenarioResult(PortfolioScenarioResult result) {
    final impactColor = result.deltaPercent >= 0
        ? AppColors.positiveGreen
        : AppColors.negativeRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: Translator.translate(
                  AppStrings.labPortfolioNewValueLabel,
                ),
                value: AppFormatters.compactCurrency(result.newValue),
                accent: impactColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: Translator.translate(AppStrings.labPortfolioDeltaLabel),
                value: AppFormatters.percent(result.deltaPercent),
                accent: impactColor,
              ),
            ),
          ],
        ),
        LabNarrativeCard(
          text: Translator.translate(
            AppStrings.labPortfolioScenarioResult,
            params: {
              'deltaPercent': result.deltaPercent.toStringAsFixed(1),
              'before': AppFormatters.currency(
                result.totalAmount,
                showCents: false,
              ),
              'after': AppFormatters.currency(
                result.newValue,
                showCents: false,
              ),
            },
          ),
          variant: LabNarrativeVariant.interpretation,
        ),
      ],
    );
  }
}

class _ScenarioChip extends StatelessWidget {
  const _ScenarioChip({
    required this.label,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final AppColorTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.neonCyan.withValues(alpha: 0.18)
                : tokens.textTertiary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected
                  ? AppColors.neonCyan.withValues(alpha: 0.7)
                  : tokens.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? tokens.textPrimary : tokens.textSecondary,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
