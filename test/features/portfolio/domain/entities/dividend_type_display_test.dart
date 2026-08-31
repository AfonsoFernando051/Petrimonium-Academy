import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_type_display.dart';

void main() {
  group('DividendTypeDisplay', () {
    test('label maps every DividendType to its display string', () {
      expect(DividendType.DIVIDENDO.label, 'Dividendo');
      expect(DividendType.JCP.label, 'JCP');
      expect(DividendType.RENDIMENTO.label, 'Rendimento');
      expect(DividendType.OUTRO.label, 'Provento');
    });

    test('color maps every DividendType to a distinct color', () {
      expect(DividendType.DIVIDENDO.color, AppColors.positiveGreen);
      expect(DividendType.JCP.color, AppColors.goldenBorder);
      expect(DividendType.RENDIMENTO.color, AppColors.neonCyan);
      expect(DividendType.OUTRO.color, AppColors.subtleText);
    });

    test('icon is defined for every DividendType', () {
      for (final type in DividendType.values) {
        expect(type.icon, isNotNull);
      }
    });
  });
}
