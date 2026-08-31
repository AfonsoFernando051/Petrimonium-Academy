import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';

/// The XP-granting CTA at the bottom of every simulator — disabled until
/// [canComplete] (the comprehension check answered correctly), and reflects
/// [LabCompletionController]'s completed state once tapped. The button
/// itself never computes or shows an XP amount — the backend is the only
/// source of truth (`docs/DECISIONS.md` DECISION-037), and completion is
/// idempotent, so re-rendering after a sync failure is always safe.
class LabCompletionFooter extends StatelessWidget {
  const LabCompletionFooter({
    super.key,
    required this.simulatorId,
    required this.resolvedTitle,
    required this.controller,
    required this.canComplete,
  });

  final LabSimulatorId simulatorId;
  final String resolvedTitle;
  final LabCompletionController controller;
  final bool canComplete;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final completed = controller.isCompleted(simulatorId);
        return GameButton(
          label: Translator.translate(
            completed ? AppStrings.labCompletedLabel : AppStrings.labCompleteButton,
          ),
          icon: completed ? Icons.check_circle : null,
          onPressed: completed || !canComplete
              ? null
              : () => controller.completeSimulator(simulatorId, resolvedTitle),
        );
      },
    );
  }
}
