import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/investment/data/repositories/investment_repository.dart';
import 'package:petrimonium/features/investment/presentation/screens/investment_configuration_screen.dart';
import 'package:petrimonium/features/investment/presentation/widgets/added_asset_tile.dart';
import 'package:petrimonium/features/investment/presentation/widgets/investment_type_selector.dart';
import 'package:petrimonium/features/investment/presentation/widgets/live_portfolio_summary_card.dart';
import 'package:petrimonium/features/investment/presentation/widgets/pet_companion_card.dart';
import 'package:petrimonium/features/investment/presentation/widgets/portfolio_progress_bar.dart';
import 'package:petrimonium/features/investment/presentation/widgets/unlockable_rewards_card.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';

class MockInvestmentRepository extends Mock implements InvestmentRepository {}

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

class MockAchievementsLocalRepository extends Mock implements AchievementsLocalRepository {}

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  late MockInvestmentRepository mockInvestmentRepository;
  late MockPortfolioRepository mockPortfolioRepository;
  late MockAchievementsLocalRepository mockAchievementsLocalRepository;
  late MockPetRepository mockPetRepository;

  setUp(() {
    mockInvestmentRepository = MockInvestmentRepository();
    mockPortfolioRepository = MockPortfolioRepository();
    mockAchievementsLocalRepository = MockAchievementsLocalRepository();
    mockPetRepository = MockPetRepository();

    when(() => mockPortfolioRepository.fetchHoldings()).thenAnswer((_) async => <Holding>[]);
    when(() => mockAchievementsLocalRepository.loadUnlocked()).thenAnswer((_) async => <String, DateTime>{});
    when(() => mockPetRepository.getMyPet()).thenAnswer((_) async => null);
    when(() => mockInvestmentRepository.searchQuotes(any())).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => mockInvestmentRepository.fetchQuoteAtDate(any(), any())).thenAnswer((_) async => null);

    DI.investmentRepository = mockInvestmentRepository;
    DI.portfolioRepository = mockPortfolioRepository;
    DI.achievementsLocalRepository = mockAchievementsLocalRepository;
    DI.petRepository = mockPetRepository;
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const InvestmentConfigurationScreen(),
    );
  }

  // The narrow (<=800px) layout stacks a 520px left panel and a 720px right
  // panel inside one outer SingleChildScrollView, taller than the default
  // 800x600 test viewport — every tap below scrolls its target into view
  // first via `ensureVisible`, which walks every ancestor Scrollable
  // (including the right panel's own inner form scroll view).
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  /// Fills the ticker/quantity/price fields and picks today's date, without
  /// selecting an investment type (callers add that separately) or tapping
  /// "Adicionar Ativo".
  Future<void> fillCommonFields(WidgetTester tester, {String ticker = 'PETR4', String quantity = '10', String price = '25'}) async {
    final textFields = find.byType(TextFormField);
    await tester.ensureVisible(textFields.at(0));
    await tester.enterText(textFields.at(0), ticker); // autocomplete ticker field
    await tester.enterText(textFields.at(1), quantity);
    await tester.enterText(textFields.at(2), price);
    await tester.pump();

    await tapVisible(tester, find.text('Data de Compra'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('OK'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Finder addAssetButton() => find.widgetWithText(GameButton, 'Adicionar Ativo');

  group('InvestmentConfigurationScreen', () {
    testWidgets('renders the left panel, the form, and a disabled confirm button with 0 assets', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Monte seu Portfólio'), findsOneWidget);
      expect(find.byType(PetCompanionCard), findsOneWidget);
      expect(find.byType(UnlockableRewardsCard), findsOneWidget);
      expect(find.byType(PortfolioProgressBar), findsOneWidget);
      // "Adicionar Ativo" appears both as the section heading and the button label.
      expect(find.text('Adicionar Ativo'), findsNWidgets(2));
      expect(addAssetButton(), findsOneWidget);
      expect(find.byType(InvestmentTypeSelector), findsOneWidget);
      expect(find.byType(LivePortfolioSummaryCard), findsOneWidget);
      expect(find.text('Adicione um ativo para continuar'), findsOneWidget);

      final confirmButton = tester.widget<GameButton>(
        find.byWidgetPredicate((w) => w is GameButton && (w.label?.startsWith('Adicione') ?? false)),
      );
      expect(confirmButton.onPressed, isNull);
    });

    testWidgets('shows an error snackbar when trying to add without selecting a type', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await fillCommonFields(tester);
      await tapVisible(tester, addAssetButton());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Selecione um tipo de ativo.'), findsOneWidget);
      expect(find.byType(AddedAssetTile), findsNothing);
    });

    testWidgets('adds an asset end-to-end: tile appears, confirm label updates, success snack shows, fields reset', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Ações')); // InvestmentTypeSelector STOCKS card shortLabel
      await fillCommonFields(tester);
      await tapVisible(tester, addAssetButton());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AddedAssetTile), findsOneWidget);
      expect(find.text('Continuar (1 ativo adicionado)'), findsOneWidget);
      expect(find.textContaining('Primeiro investimento adicionado'), findsOneWidget);

      // Fields reset after a successful add.
      final textFields = find.byType(TextFormField);
      expect(tester.widget<TextFormField>(textFields.at(1)).controller!.text, '');
      expect(tester.widget<TextFormField>(textFields.at(2)).controller!.text, '');
    });

    testWidgets('flags a ticker/type mismatch (HGLG11 under Renda Fixa) with an inline validation message', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('R. Fixa')); // FIXED_INCOME shortLabel
      await fillCommonFields(tester, ticker: 'HGLG11');
      await tapVisible(tester, addAssetButton());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('parece ser Fundos Imobiliários'), findsOneWidget);
      expect(find.byType(AddedAssetTile), findsNothing);
    });

    testWidgets('picking a purchase date fetches that date\'s historical price and fills the price field', (WidgetTester tester) async {
      when(() => mockInvestmentRepository.fetchQuoteAtDate('PETR4', any()))
          .thenAnswer((_) async => <String, dynamic>{'regularMarketPrice': 42.5});

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final textFields = find.byType(TextFormField);
      await tester.ensureVisible(textFields.at(0));
      await tester.enterText(textFields.at(0), 'PETR4');
      await tester.pump();

      await tapVisible(tester, find.text('Data de Compra'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => mockInvestmentRepository.fetchQuoteAtDate('PETR4', any())).called(1);
      expect(tester.widget<TextFormField>(textFields.at(2)).controller!.text, '42.5');
    });

    testWidgets('editing an added asset pre-fills the form and switches the button to "Salvar Alteração"', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Ações'));
      await fillCommonFields(tester, ticker: 'PETR4', quantity: '10', price: '25');
      await tapVisible(tester, addAssetButton());
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.byIcon(Icons.edit_outlined));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Salvar Alteração'), findsOneWidget);
      expect(find.byType(AddedAssetTile), findsNothing); // removed from the list while being edited

      final textFields = find.byType(TextFormField);
      expect(tester.widget<TextFormField>(textFields.at(0)).controller!.text, 'PETR4');
      expect(tester.widget<TextFormField>(textFields.at(1)).controller!.text, '10');
      expect(tester.widget<TextFormField>(textFields.at(2)).controller!.text, '25');
    });

    testWidgets('removing an added asset drops it from the list and updates the confirm label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Ações'));
      await fillCommonFields(tester);
      await tapVisible(tester, addAssetButton());
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AddedAssetTile), findsOneWidget);

      await tapVisible(tester, find.byIcon(Icons.delete_outline));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AddedAssetTile), findsNothing);
      expect(find.text('Adicione um ativo para continuar'), findsOneWidget);
    });

    testWidgets('tapping Confirm with assets calls configureInvestments and shows a friendly error on failure, without navigating away', (WidgetTester tester) async {
      when(() => mockInvestmentRepository.configureInvestments(any())).thenThrow(Exception('server exploded'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tapVisible(tester, find.text('Ações'));
      await fillCommonFields(tester);
      await tapVisible(tester, addAssetButton());
      await tester.pump(const Duration(milliseconds: 300));
      // Let the "asset added" success SnackBar (bottom of the screen, same
      // area as the Confirm button) fully dismiss before tapping — while
      // visible it absorbs the tap meant for the button underneath it.
      await tester.pump(const Duration(seconds: 5));

      final confirmButton = find.byWidgetPredicate((w) => w is GameButton && (w.label?.contains('ativo adicionado') ?? false));
      await tapVisible(tester, confirmButton);
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => mockInvestmentRepository.configureInvestments(any())).called(1);
      expect(find.textContaining('Falha ao salvar investimentos'), findsOneWidget);
      // Still on this screen — the asset tile added earlier is still present.
      expect(find.byType(AddedAssetTile), findsOneWidget);
    });
  });
}
