import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/presentation/widgets/pet_name_field.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({
    required TextEditingController controller,
    bool showError = false,
    List<String> suggestions = const ['Atlas', 'Bolt'],
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSuggestionSelected,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PetNameField(
          controller: controller,
          showError: showError,
          suggestions: suggestions,
          onChanged: onChanged ?? (_) {},
          onSuggestionSelected: onSuggestionSelected ?? (_) {},
        ),
      ),
    );
  }

  group('PetNameField', () {
    testWidgets('renders the prompt, hint and a chip per suggestion', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      expect(find.text('Como você gostaria de chamar seu companheiro?'), findsOneWidget);
      expect(find.text('Nome do companheiro'), findsOneWidget);
      expect(find.text('Atlas'), findsOneWidget);
      expect(find.text('Bolt'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('shows the required-name error only when showError is true', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildTestableWidget(controller: controller, showError: false));
      expect(find.text('Escolha um nome para continuar'), findsNothing);

      await tester.pumpWidget(buildTestableWidget(controller: controller, showError: true));
      expect(find.text('Escolha um nome para continuar'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('typing invokes onChanged', (tester) async {
      final controller = TextEditingController();
      String? changed;
      await tester.pumpWidget(buildTestableWidget(controller: controller, onChanged: (v) => changed = v));

      await tester.enterText(find.byType(TextField), 'Nino');
      expect(changed, 'Nino');

      controller.dispose();
    });

    testWidgets('tapping a suggestion chip invokes onSuggestionSelected', (tester) async {
      final controller = TextEditingController();
      String? selected;
      await tester.pumpWidget(buildTestableWidget(
        controller: controller,
        onSuggestionSelected: (v) => selected = v,
      ));

      await tester.tap(find.text('Bolt'));
      await tester.pump();

      expect(selected, 'Bolt');

      controller.dispose();
    });

    testWidgets('marks the matching suggestion chip as selected when the text matches', (tester) async {
      final controller = TextEditingController(text: 'Atlas');
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      final chip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Atlas'));
      expect(chip.selected, isTrue);

      final otherChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bolt'));
      expect(otherChip.selected, isFalse);

      controller.dispose();
    });
  });
}
