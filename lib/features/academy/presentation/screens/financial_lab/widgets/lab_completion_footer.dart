import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/widgets/wallet_bridge_cta.dart';

/// The XP-granting CTA at the bottom of every simulator — disabled until
/// [canComplete] (the comprehension check answered correctly), and reflects
/// [LabCompletionController]'s completed state once tapped. The button
/// itself never computes or shows an XP amount — the backend is the only
/// source of truth (`docs/DECISIONS.md` DECISION-037), and completion is
/// idempotent, so re-rendering after a sync failure is always safe.
///
/// Once completed, also offers [WalletBridgeCta] — the brief's §1.6
/// "see this in your real portfolio" bridge — since every Financial Lab
/// simulator maps to one of the brief's named example concepts
/// (compounding, diversification, risk/allocation, ...).
class LabCompletionFooter extends StatelessWidget {
  const LabCompletionFooter({
    super.key,
    required this.simulatorId,
    required this.resolvedTitle,
    required this.controller,
    required this.canComplete,
    required this.onOpenWallet,
  });

  final LabSimulatorId simulatorId;
  final String resolvedTitle;
  final LabCompletionController controller;
  final bool canComplete;

  /// The in-app fallback for "open Wallet" while Wallet's screens still
  /// live in this repo — see `WalletBridgeCta`'s doc comment.
  final VoidCallback? onOpenWallet;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final completed = controller.isCompleted(simulatorId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GameButton(
              label: Translator.translate(
                completed
                    ? AppStrings.labCompletedLabel
                    : AppStrings.labCompleteButton,
              ),
              icon: completed ? Icons.check_circle : null,
              onPressed: completed || !canComplete
                  ? null
                  : () => controller.completeSimulator(
                      simulatorId,
                      resolvedTitle,
                    ),
            ),
            if (completed) ...[
              const SizedBox(height: 8),
              WalletBridgeCta(onOpenWallet: onOpenWallet),
            ],
          ],
        );
      },
    );
  }
}
