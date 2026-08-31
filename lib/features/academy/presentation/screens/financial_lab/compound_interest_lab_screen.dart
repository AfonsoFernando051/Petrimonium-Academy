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
import 'package:petrimonium/features/academy/domain/services/compound_interest_calculator.dart';
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

/// The Financial Lab's Compound Interest simulator
/// (`docs/ACADEMY_ENGINE.md` §3d/§3g) — sliders drive
/// [CompoundInterestCalculator.simulate] live; the chart and explanatory
/// sentence always reflect the current inputs. Built on the shared
/// simulator architecture (`docs/DECISIONS.md` DECISION-037) — the same
/// `LabScaffold`/`LabeledSlider`/`StatCard`/`LabStackedBarChart`/
/// `LabNarrativeCard` widgets the other four Lab simulators use.
class CompoundInterestLabScreen extends StatefulWidget {
  CompoundInterestLabScreen({
    super.key,
    required this.mascotController,
    required this.companionController,
    required this.completionController,
  });

  final MascotController mascotController;
  final PetCompanionController companionController;
  final LabCompletionController completionController;

  // A fresh anchor per screen instance — Lab screens are pushed on top of
  // each other and all remain mounted simultaneously, so a shared
  // `GlobalKey` would collide (see `LabScaffold`'s doc comment).
  final PetSpeechBubbleAnchor _headerAnchor = PetSpeechBubbleAnchor();

  @override
  State<CompoundInterestLabScreen> createState() =>
      _CompoundInterestLabScreenState();
}

class _CompoundInterestLabScreenState
    extends State<CompoundInterestLabScreen> {
  double _initialAmount = 1000;
  double _monthlyContribution = 200;
  double _annualRatePercent = 8;
  int _years = 10;

  String? _explanationKey;
  Map<String, String> _explanationParams = const {};
  bool _canComplete = false;

  ChoiceQuestionStep get _comprehensionQuestion => ChoiceQuestionStep(
    framing: ChoiceStepFraming.microExercise,
    prompt: Translator.translate(AppStrings.labCompoundInterestQuestion),
    options: [
      Translator.translate(AppStrings.labCompoundInterestOptionA),
      Translator.translate(AppStrings.labCompoundInterestOptionB),
      Translator.translate(AppStrings.labCompoundInterestOptionC),
    ],
    correctIndex: 1,
    explanation: Translator.translate(
      AppStrings.labCompoundInterestAnswerExplanation,
    ),
  );

  CompoundInterestResult get _result => CompoundInterestCalculator.simulate(
    initialAmount: _initialAmount,
    monthlyContribution: _monthlyContribution,
    annualRatePercent: _annualRatePercent,
    years: _years,
  );

  void _onInitialAmountChanged(double value) {
    final from = AppFormatters.currency(_initialAmount, showCents: false);
    final to = AppFormatters.currency(value, showCents: false);
    setState(() {
      _explanationKey = value > _initialAmount
          ? AppStrings.labExplanationIncreaseInitial
          : AppStrings.labExplanationDecreaseInitial;
      _explanationParams = {'from': from, 'to': to};
      _initialAmount = value;
    });
  }

  void _onMonthlyContributionChanged(double value) {
    final from = AppFormatters.currency(
      _monthlyContribution,
      showCents: false,
    );
    final to = AppFormatters.currency(value, showCents: false);
    setState(() {
      _explanationKey = value > _monthlyContribution
          ? AppStrings.labExplanationIncreaseContribution
          : AppStrings.labExplanationDecreaseContribution;
      _explanationParams = {'from': from, 'to': to};
      _monthlyContribution = value;
    });
  }

  void _onReturnChanged(double value) {
    final rounded = double.parse(value.toStringAsFixed(1));
    if (rounded == _annualRatePercent) return;
    setState(() {
      _explanationKey = rounded > _annualRatePercent
          ? AppStrings.labExplanationIncreaseReturn
          : AppStrings.labExplanationDecreaseReturn;
      _explanationParams = {
        'from': _annualRatePercent.toStringAsFixed(1),
        'to': rounded.toStringAsFixed(1),
      };
      _annualRatePercent = rounded;
    });
  }

  void _onYearsChanged(double value) {
    final newYears = value.round();
    if (newYears == _years) return;
    setState(() {
      _explanationKey = newYears > _years
          ? AppStrings.labExplanationIncreaseYears
          : AppStrings.labExplanationDecreaseYears;
      _explanationParams = {'from': '$_years', 'to': '$newYears'};
      _years = newYears;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return LabScaffold(
      titleKey: AppStrings.labCompoundInterestTitle,
      companionController: widget.companionController,
      anchor: widget._headerAnchor,
      children: [
        LabNarrativeCard(
          text: Translator.translate(AppStrings.labCompoundInterestIntro),
          variant: LabNarrativeVariant.introduction,
        ),
        _buildInputs(context),
        _buildSummary(context, result),
        LabStackedBarChart(
          points: [
            for (final point in result.yearlyBreakdown)
              LabStackedBarPoint(
                xLabel: '${point.year}',
                base: point.contributions,
                total: point.value,
              ),
          ],
          baseColor: AppColors.neonCyan,
          growthColor: AppColors.goldenBorder,
          baseLegendLabel: Translator.translate(
            AppStrings.labTotalContributionsLabel,
          ),
          growthLegendLabel: Translator.translate(
            AppStrings.labTotalGrowthLabel,
          ),
        ),
        LabDataTableDisclosure(
          columnLabels: [
            Translator.translate(AppStrings.labYearsLabel),
            Translator.translate(AppStrings.labTotalContributionsLabel),
            Translator.translate(AppStrings.labTotalGrowthLabel),
          ],
          rows: [
            for (final point in result.yearlyBreakdown)
              LabDataTableRow(
                label: '${point.year}',
                values: [
                  AppFormatters.currency(
                    point.contributions,
                    showCents: false,
                  ),
                  AppFormatters.currency(
                    point.value - point.contributions,
                    showCents: false,
                  ),
                ],
              ),
          ],
        ),
        LabNarrativeCard(
          text: Translator.translate(
            AppStrings.labCompoundInterestInterpretation,
          ),
          variant: LabNarrativeVariant.interpretation,
        ),
        _buildTakeaway(),
        LabComprehensionCheck(
          step: _comprehensionQuestion,
          mascotController: widget.mascotController,
          onAnsweredCorrectly: () => setState(() => _canComplete = true),
        ),
        LabCompletionFooter(
          simulatorId: LabSimulatorId.compoundInterest,
          resolvedTitle: Translator.translate(
            AppStrings.labCompoundInterestTitle,
          ),
          controller: widget.completionController,
          canComplete: _canComplete,
        ),
      ],
    );
  }

  Widget _buildInputs(BuildContext context) {
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
              onChanged: _onInitialAmountChanged,
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
              onChanged: _onMonthlyContributionChanged,
            ),
            LabeledSlider(
              label: Translator.translate(AppStrings.labAnnualReturnLabel),
              valueLabel: AppFormatters.percentPlain(_annualRatePercent),
              value: _annualRatePercent,
              min: 0,
              max: 30,
              divisions: 60,
              onChanged: _onReturnChanged,
            ),
            LabeledSlider(
              label: Translator.translate(AppStrings.labYearsLabel),
              valueLabel: '$_years',
              value: _years.toDouble(),
              min: 1,
              max: 40,
              divisions: 39,
              onChanged: _onYearsChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CompoundInterestResult result) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: Translator.translate(AppStrings.labFinalValueLabel),
            value: AppFormatters.compactCurrency(result.finalValue),
            accent: AppColors.goldenBorder,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: Translator.translate(
              AppStrings.labTotalContributionsLabel,
            ),
            value: AppFormatters.compactCurrency(result.totalContributions),
            accent: AppColors.neonCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: Translator.translate(AppStrings.labTotalGrowthLabel),
            value: AppFormatters.compactCurrency(result.totalGrowth),
            accent: AppColors.neonViolet,
          ),
        ),
      ],
    );
  }

  Widget _buildTakeaway() {
    final key = _explanationKey;
    final text = key == null
        ? Translator.translate(AppStrings.labExplanationInitial)
        : Translator.translate(key, params: _explanationParams);
    return LabNarrativeCard(text: text, variant: LabNarrativeVariant.takeaway);
  }
}
