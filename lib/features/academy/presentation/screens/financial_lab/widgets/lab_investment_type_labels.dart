import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// Translated category labels for [InvestmentTypeEnum] — the real
/// Portfolio tab's `InvestmentTypeDisplay.label` is hardcoded Portuguese
/// only, so the Financial Lab (which is fully i18n'd) needs its own
/// translated labels while still reusing `.icon`/`.color` from
/// `InvestmentTypeDisplay`, which are theme/language-invariant.
extension LabInvestmentTypeLabel on InvestmentTypeEnum {
  String get labLabel => Translator.translate(switch (this) {
    InvestmentTypeEnum.STOCKS => AppStrings.labInvestmentTypeStocks,
    InvestmentTypeEnum.FIXED_INCOME => AppStrings.labInvestmentTypeFixedIncome,
    InvestmentTypeEnum.REAL_ESTATE => AppStrings.labInvestmentTypeRealEstate,
    InvestmentTypeEnum.CRYPTO => AppStrings.labInvestmentTypeCrypto,
    InvestmentTypeEnum.FUNDS => AppStrings.labInvestmentTypeFunds,
    InvestmentTypeEnum.OTHERS => AppStrings.labInvestmentTypeOthers,
  });
}
