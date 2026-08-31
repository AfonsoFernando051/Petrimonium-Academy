import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_allocation_editor.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('LabAllocationEditor', () {
    testWidgets('a valid 100% allocation shows the valid total indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          LabAllocationEditor(
            weightsPercent: const {
              InvestmentTypeEnum.STOCKS: 60,
              InvestmentTypeEnum.FIXED_INCOME: 40,
            },
            onChanged: (_, _) {},
            totalPercent: 100,
            isValid: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('an invalid allocation shows the error indicator, not the valid one', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          LabAllocationEditor(
            weightsPercent: const {
              InvestmentTypeEnum.STOCKS: 60,
              InvestmentTypeEnum.FIXED_INCOME: 20,
            },
            onChanged: (_, _) {},
            totalPercent: 80,
            isValid: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.textContaining('80%'), findsWidgets);
    });

    testWidgets('dragging a slider calls onChanged, never mutating the weights map itself', (
      tester,
    ) async {
      final weights = {
        InvestmentTypeEnum.STOCKS: 60.0,
        InvestmentTypeEnum.FIXED_INCOME: 40.0,
      };
      final before = Map.of(weights);
      InvestmentTypeEnum? changedType;
      double? changedValue;

      await tester.pumpWidget(
        wrap(
          LabAllocationEditor(
            weightsPercent: weights,
            onChanged: (type, value) {
              changedType = type;
              changedValue = value;
            },
            totalPercent: 100,
            isValid: true,
          ),
        ),
      );

      await tester.drag(find.byType(Slider).first, const Offset(100, 0));
      await tester.pump();

      expect(changedType, isNotNull);
      expect(changedValue, isNotNull);
      // The caller-owned map is never mutated by the widget itself — only
      // the callback fires; the caller decides how to update state.
      expect(weights, equals(before));
    });
  });
}
