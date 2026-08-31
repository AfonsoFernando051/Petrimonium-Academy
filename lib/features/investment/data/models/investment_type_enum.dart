// ignore_for_file: constant_identifier_names

enum InvestmentTypeEnum {
  STOCKS,
  FIXED_INCOME,
  REAL_ESTATE,
  CRYPTO,
  FUNDS,
  OTHERS
}

/// Whether this asset type is one that typically distributes dividends, JCP
/// or rendimentos to holders (ações, FIIs, ETFs/fundos) — used to decide
/// whether the Proventos tab has anything to show for the user's wallet.
/// Renda fixa pays juros/rendimento on its own schedule but isn't tracked as
/// a "provento" here, and crypto/outros have no such distribution.
extension InvestmentTypePayout on InvestmentTypeEnum {
  bool get paysDividends => switch (this) {
        InvestmentTypeEnum.STOCKS => true,
        InvestmentTypeEnum.REAL_ESTATE => true,
        InvestmentTypeEnum.FUNDS => true,
        InvestmentTypeEnum.FIXED_INCOME => false,
        InvestmentTypeEnum.CRYPTO => false,
        InvestmentTypeEnum.OTHERS => false,
      };
}
