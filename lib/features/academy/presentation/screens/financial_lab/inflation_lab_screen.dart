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
import 'package:petrimonium/features/academy/domain/services/inflation_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_comprehension_check.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_completion_footer.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_data_table_disclosure.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_line_chart.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_narrative_card.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_scaffold.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The Financial Lab's Inflation simulator (`docs/DECISIONS.md`
/// DECISION-037) — demonstrates that inflation erodes purchasing power even
/// when the nominal amount never changes, and connects that to why "real
/// return" (not nominal return alone) is what matters for investing.
class InflationLabScreen extends StatefulWidget {
  InflationLabScreen({
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

  // A fresh anchor per screen instance — see `LabScaffold`'s doc comment.
  final PetSpeechBubbleAnchor _headerAnchor = PetSpeechBubbleAnchor();

  @override
  State<InflationLabScreen> createState() => _InflationLabScreenState();
}

class _InflationLabScreenState extends State<InflationLabScreen> {
  double _initialAmount = 10000;
  double _inflationPercent = 5;
  double _nominalReturnPercent = 8;
  int _years = 10;
  bool _canComplete = false;

  InflationResult get _result => InflationCalculator.simulate(
    initialAmount: _initialAmount,
    annualInflationPercent: _inflationPercent,
    nominalReturnPercent: _nominalReturnPercent,
    years: _years,
  );

  ChoiceQuestionStep get _comprehensionQuestion => ChoiceQuestionStep(
    framing: ChoiceStepFraming.microExercise,
    prompt: Translator.translate(AppStrings.labInflationQuestion),
    options: [
      Translator.translate(AppStrings.labInflationOptionA),
      Translator.translate(AppStrings.labInflationOptionB),
      Translator.translate(AppStrings.labInflationOptionC),
    ],
    correctIndex: 1,
    explanation: Translator.translate(AppStrings.labInflationAnswerExplanation),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return LabScaffold(
      titleKey: AppStrings.labInflationTitle,
      companionController: widget.companionController,
      anchor: widget._headerAnchor,
      children: [
        LabNarrativeCard(
          text: Translator.translate(AppStrings.labInflationIntro),
          variant: LabNarrativeVariant.introduction,
        ),
        _buildInputs(),
        _buildSummary(result),
        LabLineChart(
          xLabels: [for (final p in result.yearlyBreakdown) '${p.year}'],
          series: [
            LabLineSeries(
              label: Translator.translate(
                AppStrings.labInflationNominalValueLabel,
              ),
              color: AppColors.subtleText,
              dashed: true,
              values: [for (final p in result.yearlyBreakdown) p.nominalValue],
            ),
            LabLineSeries(
              label: Translator.translate(
                AppStrings.labInflationRealValueLabel,
              ),
              color: AppColors.neonPink,
              values: [for (final p in result.yearlyBreakdown) p.realValue],
            ),
          ],
          tooltipValueFormatter: (v) =>
              AppFormatters.currency(v, showCents: false),
        ),
        LabDataTableDisclosure(
          columnLabels: [
            Translator.translate(AppStrings.labYearsLabel),
            Translator.translate(AppStrings.labInflationNominalValueLabel),
            Translator.translate(AppStrings.labInflationRealValueLabel),
          ],
          rows: [
            for (final p in result.yearlyBreakdown)
              LabDataTableRow(
                label: '${p.year}',
                values: [
                  AppFormatters.currency(p.nominalValue, showCents: false),
                  AppFormatters.currency(p.realValue, showCents: false),
                ],
              ),
          ],
        ),
        LabNarrativeCard(
          text: Translator.translate(
            AppStrings.labInflationInterpretation,
            params: {
              'rate': AppFormatters.percentPlain(_inflationPercent),
              'lostPercent': result.totalPurchasingPowerLostPercent
                  .toStringAsFixed(1),
              'years': '$_years',
              'multiplier': AppFormatters.multiplier(
                result.basketCostMultiplier,
              ),
            },
          ),
          variant: LabNarrativeVariant.interpretation,
        ),
        LabNarrativeCard(
          text: Translator.translate(
            AppStrings.labInflationInvestingConnection,
            params: {
              'nominal': AppFormatters.percentPlain(
                _nominalReturnPercent,
                decimals: 2,
              ),
              'inflation': AppFormatters.percentPlain(
                _inflationPercent,
                decimals: 2,
              ),
              'exact': (result.realReturnExact * 100).toStringAsFixed(2),
              'approx': (result.realReturnApproximate * 100).toStringAsFixed(2),
            },
          ),
          variant: LabNarrativeVariant.investingConnection,
        ),
        LabComprehensionCheck(
          step: _comprehensionQuestion,
          mascotController: widget.mascotController,
          onAnsweredCorrectly: () => setState(() => _canComplete = true),
        ),
        LabCompletionFooter(
          simulatorId: LabSimulatorId.inflation,
          resolvedTitle: Translator.translate(AppStrings.labInflationTitle),
          controller: widget.completionController,
          onOpenWallet: widget.onOpenWallet,
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
              label: Translator.translate(AppStrings.labInflationRateLabel),
              valueLabel: AppFormatters.percentPlain(_inflationPercent),
              value: _inflationPercent,
              min: 0,
              max: 20,
              divisions: 40,
              onChanged: (v) => setState(
                () => _inflationPercent = double.parse(v.toStringAsFixed(1)),
              ),
            ),
            LabeledSlider(
              label: Translator.translate(AppStrings.labAnnualReturnLabel),
              valueLabel: AppFormatters.percentPlain(_nominalReturnPercent),
              value: _nominalReturnPercent,
              min: 0,
              max: 30,
              divisions: 60,
              onChanged: (v) => setState(
                () =>
                    _nominalReturnPercent = double.parse(v.toStringAsFixed(1)),
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

  Widget _buildSummary(InflationResult result) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: Translator.translate(AppStrings.labInflationRealValueLabel),
            value: AppFormatters.compactCurrency(result.finalRealValue),
            accent: AppColors.neonPink,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: Translator.translate(
              AppStrings.labInflationLostPercentLabel,
            ),
            value:
                '${result.totalPurchasingPowerLostPercent.toStringAsFixed(1)}%',
            accent: AppColors.warningAmber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: Translator.translate(
              AppStrings.labInflationBasketMultiplierLabel,
            ),
            value: AppFormatters.multiplier(result.basketCostMultiplier),
            accent: AppColors.neonCyan,
          ),
        ),
      ],
    );
  }
}
