import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';

/// UI presentation for each [DividendType] — mirrors the pattern already
/// established by `InvestmentTypeDisplay`.
extension DividendTypeDisplay on DividendType {
  String get label => switch (this) {
        DividendType.DIVIDENDO => 'Dividendo',
        DividendType.JCP => 'JCP',
        DividendType.RENDIMENTO => 'Rendimento',
        DividendType.OUTRO => 'Provento',
      };

  Color get color => switch (this) {
        DividendType.DIVIDENDO => AppColors.positiveGreen,
        DividendType.JCP => AppColors.goldenBorder,
        DividendType.RENDIMENTO => AppColors.neonCyan,
        DividendType.OUTRO => AppColors.subtleText,
      };

  IconData get icon => switch (this) {
        DividendType.DIVIDENDO => Icons.savings_outlined,
        DividendType.JCP => Icons.account_balance_wallet_outlined,
        DividendType.RENDIMENTO => Icons.paid_outlined,
        DividendType.OUTRO => Icons.attach_money,
      };
}
