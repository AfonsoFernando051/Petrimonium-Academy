import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/controllers/simulated_wallet_controller.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/screens/place_simulated_order_screen.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/widgets/reset_simulated_wallet_dialog.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/widgets/simulated_position_tile.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/widgets/simulation_disclaimer_banner.dart';

/// Academy's "Carteira" tab — a fictitious wallet with a virtual starting
/// balance, entirely separate from any real investment account. Never
/// imports from `features/portfolio` or `features/investment` (Wallet's real
/// domain); talks only to `SimulatedWalletController`/`SimulatedWalletRepository`
/// (backend `simulated_portfolio` context).
class SimulatedWalletScreen extends StatefulWidget {
  const SimulatedWalletScreen({super.key, required this.controller});

  final SimulatedWalletController controller;

  @override
  State<SimulatedWalletScreen> createState() => _SimulatedWalletScreenState();
}

class _SimulatedWalletScreenState extends State<SimulatedWalletScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    if (!widget.controller.isLoading || widget.controller.error != null) {
      widget.controller.loadPortfolio();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openNewOrder() async {
    HapticFeedback.mediumImpact();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceSimulatedOrderScreen(controller: widget.controller)),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await ResetSimulatedWalletDialog.show(context);
    if (!confirmed) return;

    HapticFeedback.mediumImpact();
    final succeeded = await widget.controller.resetPortfolio();
    if (!mounted) return;

    if (succeeded) {
      GameSnack.show(context, Translator.translate(AppStrings.simulatedWalletResetSuccess), isSuccess: true);
    } else if (widget.controller.resetError != null) {
      GameSnack.show(context, widget.controller.resetError!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final tokens = context.colors;

    Widget body;
    if (controller.isLoading && controller.portfolio.positions.isEmpty && controller.error == null) {
      body = const AppLoadingIndicator();
    } else if (controller.error != null) {
      body = ErrorStateView(
        title: Translator.translate(AppStrings.simulatedWalletTitle),
        message: controller.error!,
        onRetry: controller.loadPortfolio,
        style: ErrorStateStyle.card,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SimulationDisclaimerBanner(),
            const SizedBox(height: AppSpacing.md),
            _BalanceCard(controller: controller),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translator.translate(AppStrings.simulatedWalletPositionsTitle),
                    style: AppTextStyles.title.copyWith(color: tokens.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (controller.portfolio.positions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        Translator.translate(AppStrings.simulatedWalletNoPositions),
                        style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
                      ),
                    )
                  else
                    for (final position in controller.portfolio.positions)
                      SimulatedPositionTile(position: position),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(Translator.translate(AppStrings.simulatedWalletTitle)),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt, color: tokens.textSecondary),
            tooltip: Translator.translate(AppStrings.simulatedWalletResetAction),
            onPressed: controller.isResetting ? null : _confirmReset,
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewOrder,
        icon: const Icon(Icons.swap_horiz),
        label: Text(Translator.translate(AppStrings.simulatedWalletNewOrderAction)),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.controller});

  final SimulatedWalletController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final portfolio = controller.portfolio;
    return GlassCard(
      surface: CardSurface.elevated,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translator.translate(AppStrings.simulatedWalletVirtualBalanceLabel),
            style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'R\$ ${portfolio.virtualBalance.toStringAsFixed(2)}',
            style: AppTextStyles.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
