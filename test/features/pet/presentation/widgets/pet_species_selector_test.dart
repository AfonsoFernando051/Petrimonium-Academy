import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/presentation/widgets/pet_species_selector.dart';

void main() {
  Widget buildTestableWidget({
    PetSpecieEnum selected = PetSpecieEnum.DOG,
    ValueChanged<PetSpecieEnum>? onSelected,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PetSpeciesSelector(selected: selected, onSelected: onSelected ?? (_) {}),
      ),
    );
  }

  group('PetSpeciesSelector', () {
    testWidgets('renders one entry per species with a capitalized label', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      for (final specie in PetSpecieEnum.values) {
        final label = specie.name[0].toUpperCase() + specie.name.substring(1).toLowerCase();
        expect(find.text(label), findsOneWidget, reason: specie.name);
      }
    });

    testWidgets('tapping a species invokes onSelected with that species', (tester) async {
      PetSpecieEnum? selected;
      await tester.pumpWidget(buildTestableWidget(onSelected: (s) => selected = s));

      await tester.tap(find.text('Cat'));
      await tester.pump();

      expect(selected, PetSpecieEnum.CAT);
    });

    testWidgets('the currently selected species is visually distinguished', (tester) async {
      await tester.pumpWidget(buildTestableWidget(selected: PetSpecieEnum.WOLF));

      final wolfLabel = tester.widget<Text>(find.text('Wolf'));
      final dogLabel = tester.widget<Text>(find.text('Dog'));

      expect(wolfLabel.style?.fontWeight, FontWeight.bold);
      expect(dogLabel.style?.fontWeight, FontWeight.normal);
    });
  });
}
