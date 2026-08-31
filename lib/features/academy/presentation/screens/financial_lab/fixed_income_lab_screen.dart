import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/labeled_slider.dart';
import 'package:petrimonium/core/widgets/stat_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/domain/services/fixed_income_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_comprehension_check.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_completion_footer.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_data_table_disclosure.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_narrative_card.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_scaffold.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_stacked_bar_chart.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The Financial Lab's Fixed Income simulator (`docs/DECISIONS.md`
/// DECISION-037) — reuses [FixedIncomeCalculator], which itself delegates
/// to the same math [CompoundInterestCalculator] uses, relabeled for
/// fixed-income vocabulary (principal/interest, nominal-vs-effective rate).
class FixedIncomeLabScreen extends StatefulWidget {
  FixedIncomeLabScreen({
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
  State<FixedIncomeLabScreen> createState() => _FixedIncomeLabScreenState();
}

class _FixedIncomeLabScreenState extends State<FixedIncomeLabScreen> {
  double _initialAmount = 5000;
  double _monthlyContribution = 300;
  double _annualRatePercent = 10;
  int _years = 10;
  bool _canComplete = false;

  FixedIncomeResult get _result => FixedIncomeCalculator.simulate(
    initialAmount: _initialAmount,
    monthlyContribution: _monthlyContribution,
    annualRatePercent: _annualRatePercent,
    years: _years,
  );

  ChoiceQuestionStep get _comprehensionQuestion => ChoiceQuestionStep(
    framing: ChoiceStepFraming.microExercise,
    prompt: Translator.translate(AppStrings.labFixedIncomeQuestion),
    options: [
      Translator.translate(AppStrings.labFixedIncomeOptionA),
      Translator.translate(AppStrings.labFixedIncomeOptionB),
      Translator.translate(AppStrings.labFixedIncomeOptionC),
    ],
    correctIndex: 1,
    explanation: Translator.translate(
      AppStrings.labFixedIncomeAnswerExplanation,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return LabScaffold(
      titleKey: AppStrings.labFixedIncomeTitle,
      companionController: widget.companionController,
      anchor: widget._headerAnchor,
      children: [
        LabNarrativeCard(
          text: Translator.translate(AppStrings.labFixedIncomeIntro),
          variant: LabNarrativeVariant.introduction,
        ),
        _buildInputs(),
        _buildSummary(result),
        LabStackedBarChart(
          points: [
            for (final p in result.yearlyBreakdown)
              LabStackedBarPoint(
                xLabel: '${p.year}',
                base: p.principal,
                total: p.value,
              ),
          ],
          baseColor: AppColors.positiveGreen,
          growthColor: AppColors.goldenBorder,
          baseLegendLabel: Translator.translate(
            AppStrings.labFixedIncomePrincipalLabel,
          ),
          growthLegendLabel: Translator.translate(
            AppStrings.labFixedIncomeInterestLabel,
          ),
        ),
        LabDataTableDisclosure(
          columnLabels: [
            Translator.translate(AppStrings.labYearsLabel),
            Translator.translate(AppStrings.labFixedIncomePrincipalLabel),
            Translator.translate(AppStrings.labFixedIncomeInterestLabel),
          ],
          rows: [
            for (final p in result.yearlyBreakdown)
              LabDataTableRow(
                label: '${p.year}',
                values: [
                  AppFormatters.currency(p.principal, showCents: false),
                  AppFormatters.currency(
                    p.value - p.principal,
                    showCents: false,
                  ),
                ],
              ),
          ],
        ),
        LabNarrativeCard(
          text: Translator.translate(
            AppStrings.labFixedIncomeInterpretation,
            params: {
              'years': '$_years',
              'interestShare': result.interestSharePercent.toStringAsFixed(1),
            },
          ),
          variant: LabNarrativeVariant.interpretation,
        ),
        LabNarrativeCard(
          text: Translator.translate(AppStrings.labFixedIncomeGrossDisclaimer),
          variant: LabNarrativeVariant.disclaimer,
        ),
        LabComprehensionCheck(
          step: _comprehensionQuestion,
          mascotController: widget.mascotController,
          onAnsweredCorrectly: () => setState(() => _canComplete = true),
        ),
        LabCompletionFooter(
          simulatorId: LabSimulatorId.fixedIncome,
          resolvedTitle: Translator.translate(AppStrings.labFixedIncomeTitle),
          controller: widget.completionController,
          canComplete: _canComplete,
        ),
      ],
    );
  }

  Widget _buildInputs() {
    return GlassCard(
      borderRadius: AppRadii.xl,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md,
          children: [
            LabeledSlider(
              label: Translator.translate(AppStrings.labInitialAmountLabel),
              valueLabel: AppFormatters.currency(
                _initialAmount,
                showCents: false,
              ),
              value: _initialAmount,
              min: 0,
              max: 100000,
              divisions: 100,
              onChanged: (v) => setState(() => _initialAmount = v),
            ),
            LabeledSlider(
              label: Translator.translate(
                AppStrings.labMonthlyContributionLabel,
              ),
              valueLabel: AppFormatters.currency(
                _monthlyContribution,
                showCents: false,
              ),
              value: _monthlyContribution,
              min: 0,
              max: 5000,
              divisions: 100,
              onChanged: (v) => setState(() => _monthlyContribution = v),
            ),
            LabeledSlider(
              label: Translator.translate(
                AppStrings.labFixedIncomeNominalRateLabel,
              ),
              valueLabel: AppFormatters.percentPlain(_annualRatePercent),
              value: _annualRatePercent,
              min: 0,
              max: 20,
              divisions: 40,
              onChanged: (v) => setState(
                () => _annualRatePercent = double.parse(v.toStringAsFixed(1)),
              ),
            ),
            LabeledSlider(
              label: Translator.translate(AppStrings.labYearsLabel),
              valueLabel: '$_years',
              value: _years.toDouble(),
              min: 1,
              max: 40,
              divisions: 39,
              onChanged: (v) => setState(() => _years = v.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(FixedIncomeResult result) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: Translator.translate(AppStrings.labFinalValueLabel),
            value: AppFormatters.compactCurrency(result.grossFinalValue),
            accent: AppColors.goldenBorder,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: Translator.translate(
              AppStrings.labFixedIncomeEffectiveRateLabel,
            ),
            value: AppFormatters.percentPlain(
              result.effectiveAnnualRatePercent,
              decimals: 2,
            ),
            accent: AppColors.neonCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: Translator.translate(
              AppStrings.labFixedIncomeInterestLabel,
            ),
            value: AppFormatters.compactCurrency(result.totalInterest),
            accent: AppColors.positiveGreen,
          ),
        ),
      ],
    );
  }
}
