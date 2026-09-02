import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/domain/services/academy_pet_behavior.dart';
import 'package:petrimonium/core/widgets/layer_chip.dart';
import 'package:petrimonium/features/pet/presentation/companion/rive/pet_rive_companion.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Renders any [ChoiceQuestionStep] (multiple choice, true/false-as-2-options,
/// or an applied scenario) with one shared widget. A wrong answer is never a
/// life/heart penalty — [_FeedbackCard] always reads as supportive — but it
/// does keep the options tappable so the learner can retry until they pick
/// the correct one (see `LessonSessionController.canAdvance`).
class ChoiceQuestionStepView extends StatelessWidget {
  const ChoiceQuestionStepView({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.answeredCorrectly,
    required this.onSelect,
    required this.mascotController,
  });

  final ChoiceQuestionStep step;

  /// The lesson's current step index — used only to vary which pet-voiced
  /// feedback line shows (`AcademyPetBehavior.questionFeedbackTitle`'s
  /// `seed`), so a multi-question lesson doesn't repeat the exact same line
  /// every time.
  final int stepIndex;
  final int? selectedIndex;

  /// True once at least one option has been picked — drives the feedback
  /// card's visibility regardless of whether that pick was right or wrong.
  final bool hasAnswered;

  /// True once the correct option has been picked — once true, options lock
  /// (see [_OptionTile.onTap]) since there's nothing left to retry.
  final bool answeredCorrectly;
  final ValueChanged<int> onSelect;
  final MascotController mascotController;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isApply = step.framing == ChoiceStepFraming.apply;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayerChip(
          label: Translator.translate(isApply ? AppStrings.academyApplyLabel : AppStrings.academyMicroExerciseLabel),
          color: tokens.mentor,
        ),
        const SizedBox(height: 10),
        Text(
          step.prompt,
          style: TextStyle(color: tokens.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, height: 1.4),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < step.options.length; i++) ...[
          _OptionTile(
            label: step.options[i],
            state: _stateFor(i),
            onTap: answeredCorrectly ? null : () => onSelect(i),
          ),
          const SizedBox(height: 8),
        ],
        if (hasAnswered) ...[
          const SizedBox(height: 8),
          _FeedbackCard(
            isCorrect: selectedIndex == step.correctIndex,
            explanation: step.explanation,
            stepIndex: stepIndex,
            mascotController: mascotController,
          ),
        ],
      ],
    );
  }

  _OptionState _stateFor(int index) {
    if (!hasAnswered) return _OptionState.neutral;
    if (index == step.correctIndex) return _OptionState.correct;
    if (index == selectedIndex) return _OptionState.incorrect;
    return _OptionState.dimmed;
  }
}

enum _OptionState { neutral, correct, incorrect, dimmed }

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.state, required this.onTap});

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final (Color borderColor, Color bgColor, IconData? trailingIcon) = switch (state) {
      _OptionState.neutral => (
          tokens.border,
          tokens.surface.withValues(alpha: context.isDarkMode ? 0.4 : 0.94),
          null,
        ),
      _OptionState.correct => (tokens.success, tokens.success.withValues(alpha: 0.14), Icons.check_circle),
      _OptionState.incorrect => (
          AppColors.neonPink,
          AppColors.neonPink.withValues(alpha: 0.12),
          Icons.cancel_outlined,
        ),
      _OptionState.dimmed => (tokens.border, tokens.surface.withValues(alpha: 0.2), null),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: state == _OptionState.dimmed ? tokens.textTertiary : tokens.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              if (trailingIcon != null) Icon(trailingIcon, color: borderColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// The lesson screen's one deliberate, minimal pet presence — see
/// `LessonScreen`'s doc comment on why nothing else here shows the pet
/// (the quietest background preset, no ambient character animation). A
/// small avatar plus a pet-voiced line at the exact moment feedback is
/// already shown reads as "my companion reacted," without adding a new
/// interruption the lesson doesn't already have (see
/// `AcademyPetBehavior.questionFeedbackTitle`'s doc comment).
class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.isCorrect,
    required this.explanation,
    required this.stepIndex,
    required this.mascotController,
  });

  final bool isCorrect;
  final String explanation;
  final int stepIndex;
  final MascotController mascotController;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    // Supportive tone either way — there's no "wrong" framing, only a next
    // beat of understanding. See ACADEMY_ENGINE.md's no-punishment rule.
    final accent = isCorrect ? tokens.success : AppColors.neonCyan;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translator.translate(
                    AcademyPetBehavior.questionFeedbackTitle(correct: isCorrect, seed: stepIndex),
                  ),
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(explanation, style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
