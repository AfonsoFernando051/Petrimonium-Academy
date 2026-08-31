import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/empty_state_view.dart';

void main() {
  Widget buildTestableWidget({
    String? title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    EmptyStateStyle style = EmptyStateStyle.standard,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: EmptyStateView(
          icon: Icons.inbox_outlined,
          title: title,
          message: message,
          actionLabel: actionLabel,
          onAction: onAction,
          style: style,
        ),
      ),
    );
  }

  group('EmptyStateView', () {
    testWidgets('renders the icon, title and message', (tester) async {
      await tester.pumpWidget(buildTestableWidget(title: 'Nothing yet', message: 'Add your first item to get started.'));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('Nothing yet'), findsOneWidget);
      expect(find.text('Add your first item to get started.'), findsOneWidget);
    });

    testWidgets('omits the title when none is given', (tester) async {
      await tester.pumpWidget(buildTestableWidget(message: 'Nothing here.'));

      expect(find.text('Nothing here.'), findsOneWidget);
      // No other Text besides the message.
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders an action button when both actionLabel and onAction are given', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(
        message: 'Nothing here.',
        actionLabel: 'Add now',
        onAction: () => tapped = true,
      ));

      expect(find.byType(TextButton), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders no action button when onAction is omitted', (tester) async {
      await tester.pumpWidget(buildTestableWidget(message: 'Nothing here.', actionLabel: 'Ignored without onAction'));

      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('compact style uses a smaller icon than standard', (tester) async {
      await tester.pumpWidget(buildTestableWidget(message: 'msg', style: EmptyStateStyle.compact));

      final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_outlined));
      expect(icon.size, 32);
    });

    testWidgets('standard style uses the larger icon size', (tester) async {
      await tester.pumpWidget(buildTestableWidget(message: 'msg'));

      final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_outlined));
      expect(icon.size, 48);
    });
  });
}
