import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// UI presentation (label/icon/color/ideal target) for each backend
/// [InvestmentTypeEnum]. Kept in the portfolio feature — rather than added to
/// the investment feature's plain data enum — since it's presentation-only
/// concern specific to this screen.
extension InvestmentTypeDisplay on InvestmentTypeEnum {
  String get label => switch (this) {
        InvestmentTypeEnum.STOCKS => 'Ações',
        InvestmentTypeEnum.FIXED_INCOME => 'Renda Fixa',
        InvestmentTypeEnum.REAL_ESTATE => 'Fundos Imobiliários',
        InvestmentTypeEnum.CRYPTO => 'Cripto',
        InvestmentTypeEnum.FUNDS => 'ETFs & Fundos',
        InvestmentTypeEnum.OTHERS => 'Outros',
      };

  String get shortLabel => switch (this) {
        InvestmentTypeEnum.STOCKS => 'Ações',
        InvestmentTypeEnum.FIXED_INCOME => 'R. Fixa',
        InvestmentTypeEnum.REAL_ESTATE => 'FIIs',
        InvestmentTypeEnum.CRYPTO => 'Cripto',
        InvestmentTypeEnum.FUNDS => 'ETFs',
        InvestmentTypeEnum.OTHERS => 'Outros',
      };

  IconData get icon => switch (this) {
        InvestmentTypeEnum.STOCKS => Icons.show_chart,
        InvestmentTypeEnum.FIXED_INCOME => Icons.account_balance,
        InvestmentTypeEnum.REAL_ESTATE => Icons.apartment,
        InvestmentTypeEnum.CRYPTO => Icons.currency_bitcoin,
        InvestmentTypeEnum.FUNDS => Icons.pie_chart,
        InvestmentTypeEnum.OTHERS => Icons.category,
      };

  Color get color => switch (this) {
        InvestmentTypeEnum.STOCKS => AppColors.neonCyan,
        InvestmentTypeEnum.FIXED_INCOME => AppColors.positiveGreen,
        InvestmentTypeEnum.REAL_ESTATE => AppColors.goldenBorder,
        InvestmentTypeEnum.CRYPTO => AppColors.neonPink,
        InvestmentTypeEnum.FUNDS => AppColors.neonPurple,
        InvestmentTypeEnum.OTHERS => AppColors.subtleText,
      };

  /// Suggested balanced-portfolio target, expressed as a percent of total
  /// current value. This is a simple, editable-in-future heuristic (not a
  /// personalized recommendation engine) used to power the allocation
  /// "ideal vs current" comparison and rebalance insights.
  double get idealTargetPercent => switch (this) {
        InvestmentTypeEnum.STOCKS => 35,
        InvestmentTypeEnum.FIXED_INCOME => 30,
        InvestmentTypeEnum.REAL_ESTATE => 15,
        InvestmentTypeEnum.FUNDS => 12,
        InvestmentTypeEnum.CRYPTO => 5,
        InvestmentTypeEnum.OTHERS => 3,
      };

  /// Assumed average annual yield used only to *estimate* passive income,
  /// since no real dividend/coupon data source exists yet. Always surfaced
  /// to the user as "estimated", never presented as a confirmed payment.
  double get assumedAnnualYield => switch (this) {
        InvestmentTypeEnum.STOCKS => 0.05,
        InvestmentTypeEnum.FIXED_INCOME => 0.11,
        InvestmentTypeEnum.REAL_ESTATE => 0.08,
        InvestmentTypeEnum.FUNDS => 0.04,
        InvestmentTypeEnum.CRYPTO => 0.0,
        InvestmentTypeEnum.OTHERS => 0.0,
      };
}
