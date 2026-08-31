import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// The brief's §1.6 "See this applied to your real portfolio in Wallet" CTA
/// — offered once a Financial Lab simulator is completed. [onOpenWallet] is
/// the caller's current best way to get the user there:
///
/// - Today, Wallet's screens still live in this repo (see the "leave in
///   place, build alongside" decision), so callers pass an in-app tab
///   switch — never `null` in that case.
/// - `null` means genuinely nothing is reachable right now (e.g. a future
///   caller with no Wallet app installed and no in-app fallback) — renders
///   as a disabled "coming soon" state instead of a broken link, per the
///   brief's graceful-degradation requirement. Never omit this widget
///   entirely for that case; a visible, disabled state is what tells the
///   user this is coming rather than silently absent.
class WalletBridgeCta extends StatelessWidget {
  const WalletBridgeCta({super.key, required this.onOpenWallet});

  final VoidCallback? onOpenWallet;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final available = onOpenWallet != null;
    return TextButton.icon(
      onPressed: onOpenWallet,
      icon: Icon(
        Icons.account_balance_wallet_outlined,
        size: 18,
        color: available ? tokens.primary : tokens.textTertiary,
      ),
      label: Text(
        Translator.translate(
          available
              ? AppStrings.walletBridgeCtaLabel
              : AppStrings.walletBridgeComingSoon,
        ),
        style: TextStyle(
          color: available ? tokens.primary : tokens.textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
