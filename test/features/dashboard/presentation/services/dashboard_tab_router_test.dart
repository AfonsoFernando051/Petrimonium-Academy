import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/features/dashboard/presentation/services/dashboard_tab_router.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';

void main() {
  group('DashboardTabRouter.petContextFor', () {
    test('Home tab maps to PetContext.home', () {
      expect(DashboardTabRouter.petContextFor(DashboardTabRouter.homeTab), PetContext.home);
    });

    test('Academy tab maps to PetContext.academy', () {
      expect(DashboardTabRouter.petContextFor(DashboardTabRouter.academyTab), PetContext.academy);
    });

    test('Wallet and Passive Income tabs share PetContext.portfolio', () {
      expect(DashboardTabRouter.petContextFor(DashboardTabRouter.walletTab), PetContext.portfolio);
      expect(DashboardTabRouter.petContextFor(DashboardTabRouter.passiveIncomeTab), PetContext.portfolio);
    });

    test('Mentor tab (and any other index) maps to PetContext.mentor', () {
      expect(DashboardTabRouter.petContextFor(DashboardTabRouter.mentorTab), PetContext.mentor);
    });
  });

  group('DashboardTabRouter.backgroundIntensityFor', () {
    test('Home is immersive', () {
      expect(DashboardTabRouter.backgroundIntensityFor(DashboardTabRouter.homeTab), BackgroundIntensity.immersive);
    });

    test('Academy is subtle', () {
      expect(DashboardTabRouter.backgroundIntensityFor(DashboardTabRouter.academyTab), BackgroundIntensity.subtle);
    });

    test('Wallet and Passive Income are balanced', () {
      expect(DashboardTabRouter.backgroundIntensityFor(DashboardTabRouter.walletTab), BackgroundIntensity.balanced);
      expect(DashboardTabRouter.backgroundIntensityFor(DashboardTabRouter.passiveIncomeTab), BackgroundIntensity.balanced);
    });

    test('Mentor has its own mentor intensity', () {
      expect(DashboardTabRouter.backgroundIntensityFor(DashboardTabRouter.mentorTab), BackgroundIntensity.mentor);
    });
  });

  group('DashboardTabRouter.showsHoldingsCount', () {
    test('true only for Wallet/Passive Income', () {
      expect(DashboardTabRouter.showsHoldingsCount(DashboardTabRouter.walletTab), isTrue);
      expect(DashboardTabRouter.showsHoldingsCount(DashboardTabRouter.passiveIncomeTab), isTrue);
      expect(DashboardTabRouter.showsHoldingsCount(DashboardTabRouter.homeTab), isFalse);
      expect(DashboardTabRouter.showsHoldingsCount(DashboardTabRouter.academyTab), isFalse);
      expect(DashboardTabRouter.showsHoldingsCount(DashboardTabRouter.mentorTab), isFalse);
    });
  });

  group('DashboardFormatters.notificationBadgeLabel', () {
    test('renders the exact count at or below 9', () {
      expect(DashboardFormatters.notificationBadgeLabel(0), '0');
      expect(DashboardFormatters.notificationBadgeLabel(9), '9');
    });

    test('caps at "9+" above 9', () {
      expect(DashboardFormatters.notificationBadgeLabel(10), '9+');
      expect(DashboardFormatters.notificationBadgeLabel(123), '9+');
    });
  });
}
