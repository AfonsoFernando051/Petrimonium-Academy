import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/applied_concept.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_indicator.dart';
import 'package:petrimonium/features/asset_details/domain/entities/educational_explanation.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/applied_learning_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/indicator_education_sheet.dart';

const _asset = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', assetType: 'stock', priceToEarnings: 8.5);

const _peApplied = AppliedConcept(
  indicator: AssetIndicator(id: 'pe', label: 'P/L', value: '8.50', rawValue: 8.5, unit: 'x'),
  explanation: EducationalExplanation(
    indicatorId: 'pe',
    title: 'O que é P/L?',
    definition: 'def',
    whyItMatters: 'Ajuda a entender se a ação está cara ou barata.',
    caveat: 'caveat',
  ),
  lessonId: 'fundamental_analysis_pl_pvp',
  lessonTitle: 'P/L e P/VP',
);

void main() {
  Widget buildTestableWidget(List<AppliedConcept> appliedConcepts) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AppliedLearningCard(asset: _asset, appliedConcepts: appliedConcepts)),
    );
  }

  group('AppliedLearningCard', () {
    testWidgets('renders nothing when there are no applied concepts', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const []));

      expect(find.byType(AppliedLearningCard), findsOneWidget);
      expect(find.text('APLIQUE O QUE VOCÊ APRENDEU'), findsNothing);
    });

    testWidgets('renders the lesson title, indicator label/value and explanation snippet', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const [_peApplied]));

      expect(find.text('APLIQUE O QUE VOCÊ APRENDEU'), findsOneWidget);
      expect(
        find.text('Você aprendeu sobre P/L em "P/L e P/VP" — veja como isso aparece em Petrobras hoje:'),
        findsOneWidget,
      );
      expect(find.text('P/L'), findsOneWidget);
      expect(find.text('8.50'), findsOneWidget);
      expect(find.text('Ajuda a entender se a ação está cara ou barata.'), findsOneWidget);
    });

    testWidgets('tapping a tile opens the IndicatorEducationSheet for that indicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const [_peApplied]));

      await tester.tap(find.text('P/L'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(IndicatorEducationSheet), findsOneWidget);
    });

    testWidgets('renders one tile per applied concept', (tester) async {
      const roeApplied = AppliedConcept(
        indicator: AssetIndicator(id: 'roe', label: 'ROE', value: '22.0%', rawValue: 0.22, unit: '%'),
        explanation: EducationalExplanation(
          indicatorId: 'roe',
          title: 'O que é ROE?',
          definition: 'def',
          whyItMatters: 'Mostra a eficiência da empresa.',
          caveat: 'caveat',
        ),
        lessonId: 'fundamental_analysis_roe',
        lessonTitle: 'ROE',
      );

      await tester.pumpWidget(buildTestableWidget(const [_peApplied, roeApplied]));

      expect(find.text('P/L'), findsOneWidget);
      expect(find.text('ROE'), findsOneWidget);
    });
  });
}
