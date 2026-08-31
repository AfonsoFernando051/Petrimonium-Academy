import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/presentation/widgets/investment_field_style.dart';

/// `investment_field_style.dart` holds pure style helpers (no widget state,
/// no behavior) shared by every input field on the investment configuration
/// screen — these tests just pin down the values they return given a
/// BuildContext, not any rendered UI.
void main() {
  late BuildContext capturedContext;

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const Scaffold(body: SizedBox());
        },
      ),
    );
  }

  group('investmentFieldFill', () {
    testWidgets('returns the surface color from the current theme tokens', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final fill = investmentFieldFill(capturedContext);

      expect(fill, isA<Color>());
    });
  });

  group('investmentFieldBorder', () {
    testWidgets('defaults to a neon-cyan border at 0.4 alpha', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final border = investmentFieldBorder();

      expect(border.top.color.toARGB32(), AppColors.neonCyan.withValues(alpha: 0.4).toARGB32());
    });

    testWidgets('honors a custom alpha', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final border = investmentFieldBorder(alpha: 1.0);

      expect(border.top.color.toARGB32(), AppColors.neonCyan.withValues(alpha: 1.0).toARGB32());
    });
  });

  group('investmentInputDecoration', () {
    testWidgets('carries the given label and fills the field', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final decoration = investmentInputDecoration(capturedContext, label: 'Qtd.');

      expect(decoration.labelText, 'Qtd.');
      expect(decoration.filled, isTrue);
      expect(decoration.border, isA<OutlineInputBorder>());
    });

    testWidgets('carries a suffix icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      const suffix = Icon(Icons.calendar_today);
      final decoration = investmentInputDecoration(capturedContext, label: 'Data', suffixIcon: suffix);

      expect(decoration.suffixIcon, suffix);
    });

    testWidgets('has no suffix icon by default', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final decoration = investmentInputDecoration(capturedContext, label: 'Nome');

      expect(decoration.suffixIcon, isNull);
    });
  });
}
