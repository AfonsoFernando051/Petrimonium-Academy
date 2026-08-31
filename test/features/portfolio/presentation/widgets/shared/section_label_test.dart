import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  group('SectionLabel', () {
    testWidgets('renders the label text without a Row when no trailing widget is given', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SectionLabel('HOLDINGS')));

      expect(find.text('HOLDINGS'), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('renders the trailing widget in a Row when provided', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SectionLabel('HOLDINGS', trailing: Icon(Icons.add)),
      ));

      expect(find.text('HOLDINGS'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });
  });
}
