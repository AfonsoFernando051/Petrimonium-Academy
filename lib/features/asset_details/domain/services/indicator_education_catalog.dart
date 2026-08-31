import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_indicator.dart';
import 'package:petrimonium/features/asset_details/domain/entities/educational_explanation.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// Static catalog of indicator explanations and asset-type-aware indicator
/// builders. This is educational content — not market data — so it's
/// hardcoded rather than fetched from a server.
///
/// Each indicator has:
/// - A short explanation of what it is
/// - Why it matters to investors
/// - An important caveat (it should never be used in isolation)
/// - An optional pet dialogue for the Character Engine
class IndicatorEducationCatalog {
  IndicatorEducationCatalog._();

  // ── Educational explanations ─────────────────────────────────────────

  static const Map<String, EducationalExplanation> _explanations = {
    'pe': EducationalExplanation(
      indicatorId: 'pe',
      title: 'O que é P/L (Preço/Lucro)?',
      definition:
          'O P/L compara o preço atual da ação com o lucro por ação gerado pela empresa. '
          'Ele mostra quantos anos de lucro seriam necessários para "pagar" o preço da ação, '
          'mantendo o lucro atual constante.',
      whyItMatters:
          'Investidores usam o P/L para ter uma ideia se a ação está cara ou barata em relação '
          'ao que a empresa gera de lucro. Um P/L muito alto pode indicar expectativa de crescimento; '
          'um P/L baixo pode indicar subvalorização — ou problemas.',
      caveat:
          'O P/L não deve ser analisado isoladamente. Empresas em setores diferentes têm P/Ls '
          'naturalmente diferentes. Compare sempre com empresas do mesmo setor.',
      petDialogue: 'Vamos entender o P/L! É como perguntar: "Quantos anos de lucro pagam esse preço?"',
    ),
    'pvp': EducationalExplanation(
      indicatorId: 'pvp',
      title: 'O que é P/VP (Preço/Valor Patrimonial)?',
      definition:
          'O P/VP compara o preço de mercado de uma ação ou cota com o valor patrimonial por ação/cota. '
          'Em fundos imobiliários, ele mostra se você está pagando mais ou menos do que o valor dos ativos do fundo.',
      whyItMatters:
          'Um P/VP abaixo de 1 pode indicar que o mercado está avaliando o ativo abaixo do seu patrimônio líquido. '
          'Acima de 1, o mercado está pagando um prêmio. Em FIIs, é um dos indicadores mais acompanhados.',
      caveat:
          'P/VP não é garantia de que algo está "barato" ou "caro". O valor patrimonial pode estar '
          'desatualizado, e o mercado pode ter boas razões para precificar diferente.',
      petDialogue: 'P/VP compara o preço com o valor dos ativos. Quer saber por que investidores olham para isso?',
    ),
    'dy': EducationalExplanation(
      indicatorId: 'dy',
      title: 'O que é Dividend Yield?',
      definition:
          'O Dividend Yield (DY) mostra quanto uma ação ou fundo distribuiu em dividendos nos últimos 12 meses, '
          'em relação ao preço atual. É expresso como uma porcentagem.',
      whyItMatters:
          'Investidores focados em renda passiva usam o DY para entender quanto retorno recebem em forma de '
          'dividendos. Um DY alto pode ser atraente, mas precisa ser sustentável.',
      caveat:
          'Um DY muito alto pode ser insustentável — a empresa ou fundo pode estar distribuindo mais do que gera. '
          'DY passado não garante DY futuro.',
      petDialogue: 'Dividend Yield mostra quanto você recebe de volta. Vamos entender juntos!',
    ),
    'roe': EducationalExplanation(
      indicatorId: 'roe',
      title: 'O que é ROE (Retorno sobre Patrimônio)?',
      definition:
          'O ROE mede quanto lucro líquido a empresa gera em relação ao seu patrimônio líquido. '
          'Em termos simples: mostra quão eficiente a empresa é em gerar lucro com o dinheiro dos acionistas.',
      whyItMatters:
          'Um ROE alto geralmente indica uma empresa eficiente. Investidores gostam de empresas que '
          'conseguem gerar bons retornos com relativamente pouco capital próprio.',
      caveat:
          'Um ROE alto por causa de dívida excessiva pode ser enganoso. Sempre analise o ROE junto '
          'com o endividamento da empresa.',
      petDialogue: 'ROE mostra a eficiência da empresa. Vamos ver o que esse número quer dizer!',
    ),
    'roa': EducationalExplanation(
      indicatorId: 'roa',
      title: 'O que é ROA (Retorno sobre Ativos)?',
      definition:
          'O ROA mede quanto lucro líquido a empresa gera em relação ao total de seus ativos. '
          'Ele mostra quão bem a empresa usa todos os seus recursos para gerar lucro.',
      whyItMatters:
          'Diferente do ROE, o ROA considera o total de ativos (incluindo o que é financiado por dívida). '
          'Útil para comparar empresas com diferentes níveis de endividamento.',
      caveat:
          'Setores diferentes têm ROAs naturalmente diferentes. Empresas que precisam de muitos ativos '
          '(indústria, infraestrutura) tendem a ter ROAs menores.',
      petDialogue: 'ROA mostra como a empresa usa seus recursos. Vamos explorar!',
    ),
    'net_margin': EducationalExplanation(
      indicatorId: 'net_margin',
      title: 'O que é Margem Líquida?',
      definition:
          'A Margem Líquida mostra qual porcentagem da receita se transforma em lucro líquido '
          'depois de todos os custos, despesas e impostos.',
      whyItMatters:
          'Uma margem líquida alta indica que a empresa consegue manter uma boa parte da receita como lucro. '
          'Margens baixas podem indicar competição intensa ou custos altos.',
      caveat:
          'Compare margens líquidas entre empresas do mesmo setor. Setores diferentes têm margens naturalmente diferentes.',
      petDialogue: 'Margem Líquida mostra quanto do que a empresa ganha vira lucro de verdade.',
    ),
    'market_cap': EducationalExplanation(
      indicatorId: 'market_cap',
      title: 'O que é Valor de Mercado?',
      definition:
          'O Valor de Mercado (Market Cap) é o preço total que o mercado atribui à empresa. '
          'É calculado multiplicando o preço da ação pelo número total de ações.',
      whyItMatters:
          'O valor de mercado ajuda a entender o tamanho da empresa. Empresas maiores tendem a ser mais '
          'estáveis, enquanto empresas menores podem crescer mais rápido — mas com mais risco.',
      caveat:
          'Valor de mercado alto não significa que a empresa é "boa" ou "cara". É apenas o tamanho dela '
          'no mercado.',
      petDialogue: 'Valor de mercado mostra o tamanho da empresa. Vamos entender o que isso significa!',
    ),
    'ev_ebitda': EducationalExplanation(
      indicatorId: 'ev_ebitda',
      title: 'O que é EV/EBITDA?',
      definition:
          'O EV/EBITDA compara o valor total da empresa (incluindo dívida) com sua geração de caixa '
          'operacional. É similar ao P/L, mas considera a dívida e desconsidera impostos e depreciação.',
      whyItMatters:
          'É útil para comparar empresas com diferentes níveis de endividamento e estruturas de capital. '
          'Muitos analistas preferem o EV/EBITDA ao P/L para comparações mais justas.',
      caveat:
          'O EBITDA não considera reinvestimentos necessários (CAPEX). Empresas que precisam investir muito '
          'podem parecer mais baratas do que realmente são.',
      petDialogue: 'EV/EBITDA é como o P/L, mas mais completo. Quer saber por quê?',
    ),
    'debt_equity': EducationalExplanation(
      indicatorId: 'debt_equity',
      title: 'O que é Dívida/Patrimônio?',
      definition:
          'A relação Dívida/Patrimônio mostra quanto de dívida a empresa tem em comparação com '
          'o capital dos acionistas. Um valor de 1 significa que a dívida é igual ao patrimônio.',
      whyItMatters:
          'Empresas com muita dívida podem ser mais vulneráveis em crises. Por outro lado, '
          'dívida controlada pode ser saudável para financiar crescimento.',
      caveat:
          'Alguns setores (bancos, utilities) naturalmente operam com mais dívida. Compare sempre '
          'com empresas do mesmo setor.',
      petDialogue: 'Essa métrica mostra o equilíbrio entre dívida e capital próprio. Vamos explorar!',
    ),
    'vacancy': EducationalExplanation(
      indicatorId: 'vacancy',
      title: 'O que é Vacância?',
      definition:
          'A vacância mostra a porcentagem dos imóveis de um fundo imobiliário que estão desocupados, '
          'ou seja, sem gerar receita de aluguel.',
      whyItMatters:
          'Vacância alta significa menos receita de aluguel e, potencialmente, menores distribuições '
          'para os cotistas. Fundos com vacância baixa tendem a gerar renda mais estável.',
      caveat:
          'Uma vacância temporária (por reforma ou troca de inquilino) pode ser diferente de uma '
          'vacância estrutural. O contexto importa.',
      petDialogue: 'Vacância mostra quantos imóveis estão vazios. Isso afeta diretamente a renda do fundo!',
    ),
  };

  /// Returns the educational explanation for a given indicator ID,
  /// or null if no explanation exists.
  static EducationalExplanation? getExplanation(String indicatorId) {
    return _explanations[indicatorId];
  }

  /// Returns all available explanations (useful for a "learn all" screen).
  static List<EducationalExplanation> get allExplanations =>
      _explanations.values.toList();

  // ── Indicator builders per asset type ────────────────────────────────

  /// Builds the relevant indicators for a given asset, adapting to its type.
  /// Only returns indicators that have actual data — never fabricates.
  static List<AssetIndicator> buildIndicators(AssetDetails asset) {
    switch (asset.assetType) {
      case 'fii':
        return _buildFiiIndicators(asset);
      case 'etf':
        return _buildEtfIndicators(asset);
      case 'bdr':
      case 'stock':
      default:
        return _buildStockIndicators(asset);
    }
  }

  static List<AssetIndicator> _buildStockIndicators(AssetDetails asset) {
    return <AssetIndicator>[
      if (asset.priceToEarnings != null)
        AssetIndicator(
          id: 'pe', label: 'P/L',
          value: asset.priceToEarnings!.toStringAsFixed(2),
          rawValue: asset.priceToEarnings, unit: 'x',
        ),
      if (asset.priceToBook != null)
        AssetIndicator(
          id: 'pvp', label: 'P/VP',
          value: asset.priceToBook!.toStringAsFixed(2),
          rawValue: asset.priceToBook, unit: 'x',
        ),
      if (asset.dividendYield != null)
        AssetIndicator(
          id: 'dy', label: 'DY 12M',
          value: '${asset.dividendYield!.toStringAsFixed(2)}%',
          rawValue: asset.dividendYield, unit: '%',
        ),
      if (asset.evToEbitda != null)
        AssetIndicator(
          id: 'ev_ebitda', label: 'EV/EBITDA',
          value: asset.evToEbitda!.toStringAsFixed(2),
          rawValue: asset.evToEbitda, unit: 'x',
        ),
      if (asset.returnOnEquity != null)
        AssetIndicator(
          id: 'roe', label: 'ROE',
          value: '${(asset.returnOnEquity! * 100).toStringAsFixed(1)}%',
          rawValue: asset.returnOnEquity, unit: '%',
        ),
      if (asset.returnOnAssets != null)
        AssetIndicator(
          id: 'roa', label: 'ROA',
          value: '${(asset.returnOnAssets! * 100).toStringAsFixed(1)}%',
          rawValue: asset.returnOnAssets, unit: '%',
        ),
      if (asset.netMargin != null)
        AssetIndicator(
          id: 'net_margin', label: 'Margem Líquida',
          value: '${(asset.netMargin! * 100).toStringAsFixed(1)}%',
          rawValue: asset.netMargin, unit: '%',
        ),
      if (asset.marketCap != null)
        AssetIndicator(
          id: 'market_cap', label: 'Valor de Mercado',
          value: AppFormatters.compactCurrency(asset.marketCap!),
          rawValue: asset.marketCap, unit: 'R\$',
        ),
      if (asset.debtToEquity != null)
        AssetIndicator(
          id: 'debt_equity', label: 'Dívida/PL',
          value: asset.debtToEquity!.toStringAsFixed(2),
          rawValue: asset.debtToEquity, unit: 'x',
        ),
    ];
  }

  static List<AssetIndicator> _buildFiiIndicators(AssetDetails asset) {
    return <AssetIndicator>[
      if (asset.dividendYield != null)
        AssetIndicator(
          id: 'dy', label: 'DY 12M',
          value: '${asset.dividendYield!.toStringAsFixed(2)}%',
          rawValue: asset.dividendYield, unit: '%',
        ),
      if (asset.pvp != null || asset.priceToBook != null)
        AssetIndicator(
          id: 'pvp', label: 'P/VP',
          value: (asset.pvp ?? asset.priceToBook)!.toStringAsFixed(2),
          rawValue: asset.pvp ?? asset.priceToBook, unit: 'x',
        ),
      if (asset.marketCap != null)
        AssetIndicator(
          id: 'market_cap', label: 'Valor de Mercado',
          value: AppFormatters.compactCurrency(asset.marketCap!),
          rawValue: asset.marketCap, unit: 'R\$',
        ),
      if (asset.netAssetValue != null)
        AssetIndicator(
          id: 'nav', label: 'VP por Cota',
          value: AppFormatters.currency(asset.netAssetValue!),
          rawValue: asset.netAssetValue, unit: 'R\$',
        ),
    ];
  }

  static List<AssetIndicator> _buildEtfIndicators(AssetDetails asset) {
    return <AssetIndicator>[
      if (asset.marketCap != null)
        AssetIndicator(
          id: 'market_cap', label: 'Patrimônio',
          value: AppFormatters.compactCurrency(asset.marketCap!),
          rawValue: asset.marketCap, unit: 'R\$',
        ),
      if (asset.dividendYield != null)
        AssetIndicator(
          id: 'dy', label: 'DY 12M',
          value: '${asset.dividendYield!.toStringAsFixed(2)}%',
          rawValue: asset.dividendYield, unit: '%',
        ),
    ];
  }

  // ── Suggested questions per asset type ───────────────────────────────

  /// Returns contextual suggested questions for the AI mentor based
  /// on the current asset. The user shouldn't need to type manually.
  static List<String> suggestedQuestions(AssetDetails asset) {
    final questions = <String>[
      'O que é ${asset.displayName}?',
      'Como esse ativo se encaixa na minha carteira?',
      'Quais riscos devo entender?',
    ];

    if (asset.isFii) {
      questions.addAll([
        'O que é P/VP em fundos imobiliários?',
        'Como funciona a distribuição de rendimentos?',
        'O que é vacância e por que importa?',
      ]);
    } else if (asset.isStock) {
      questions.addAll([
        'O que o P/L desse ativo significa?',
        'Essa empresa tem boa saúde financeira?',
        'Como funcionam os dividendos de ações?',
      ]);
    } else if (asset.isEtf) {
      questions.addAll([
        'O que esse ETF replica?',
        'Quais são as vantagens de investir via ETF?',
        'O que é taxa de administração?',
      ]);
    }

    questions.add('Explique como se eu fosse iniciante.');
    return questions;
  }
}
