import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/settings/presentation/widgets/companion_section.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({String? petName, VoidCallback? onRename}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: CompanionSection(
          sectionLabel: (label) => Text(label),
          petName: petName,
          onRename: onRename ?? () {},
        ),
      ),
    );
  }

  group('CompanionSection', () {
    testWidgets('renders section label and pet name', (tester) async {
      await tester.pumpWidget(buildTestableWidget(petName: 'Rex'));

      expect(find.text('COMPANHEIRO'), findsOneWidget);
      expect(find.text('Nome do companheiro'), findsOneWidget);
      expect(find.text('Rex'), findsOneWidget);
      expect(find.text('Renomear'), findsOneWidget);
    });

    testWidgets('renders a dash placeholder when petName is null', (tester) async {
      await tester.pumpWidget(buildTestableWidget(petName: null));

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('renders a dash placeholder when petName is empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget(petName: ''));

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('invokes onRename when the rename button is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(petName: 'Rex', onRename: () => tapped = true));

      await tester.tap(find.text('Renomear'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
