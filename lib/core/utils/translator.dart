import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

/// App-wide translator. pt-BR is the product's default language; en/es are
/// offered through the Settings screen. [languageNotifier] lets widgets
/// rebuild reactively when the user switches language without pulling in a
/// state-management package, matching this project's existing DI-by-static-class style.
class Translator {
  Translator._();

  static const String _prefsKey = 'app_language';
  static const String defaultLanguage = 'pt';
  static const Set<String> supportedLanguages = {'pt', 'en', 'es'};

  static final ValueNotifier<String> languageNotifier = ValueNotifier(
    defaultLanguage,
  );

  static String get currentLanguage => languageNotifier.value;

  /// Synchronous setter kept for tests and simple in-memory switches.
  /// Prefer [setLanguage] in the app so the preference is persisted.
  static set currentLanguage(String language) {
    languageNotifier.value = language;
  }

  /// Loads the persisted language preference. Call once during app startup,
  /// before the first screen is built.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && supportedLanguages.contains(saved)) {
      languageNotifier.value = saved;
    }
  }

  /// Updates the current language and persists it locally.
  /// Does not call the backend — callers that need the preference synced
  /// server-side (e.g. the Settings screen) should do that separately.
  static Future<void> setLanguage(String language) async {
    if (!supportedLanguages.contains(language)) return;
    languageNotifier.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'pt': {
      AppStrings.welcomeBack: "Bem-vindo de volta",
      AppStrings.loginToContinue: "Faça login para continuar",
      AppStrings.emailOrUserHint: "E-mail ou Usuário",
      AppStrings.passwordHint: "Senha",
      AppStrings.forgotPassword: "Esqueceu a senha?",
      AppStrings.noAccountSignUp: "Não tem conta? Cadastre-se",
      AppStrings.loginButton: "Entrar",
      AppStrings.continueWithGoogle: "Continuar com Google",
      AppStrings.orDivider: "ou",
      AppStrings.createAccount: "Criar Conta",
      AppStrings.fillDetails: "Preencha seus dados",
      AppStrings.nameHint: "Nome Completo",
      AppStrings.confirmPasswordHint: "Confirmar Senha",
      AppStrings.signupButton: "Cadastrar",
      AppStrings.alreadyHaveAccount: "Já tem conta? Entrar",

      AppStrings.pleaseAnswerAllQuestions: "Responda todas as perguntas",
      AppStrings.onboardingFailed: "Falha ao enviar respostas",
      AppStrings.noQuestionsAvailable: "Nenhuma pergunta disponível.",
      AppStrings.failedToLoadQuestions: "Falha ao carregar perguntas",

      AppStrings.petProfileTitle: "Perfil do PET",
      AppStrings.failedToSavePet: "Falha ao salvar o pet",

      AppStrings.meetPetTitle: "Conheça seu Companheiro",
      AppStrings.meetPetGreeting: "Olá!",
      AppStrings.meetPetIntro:
          "Sou o seu companheiro financeiro. Vou te ajudar a aprender sobre investimentos, manter a disciplina e comemorar cada conquista da sua jornada.",
      AppStrings.meetPetNeedName: "Mas antes... eu preciso de um nome!",
      AppStrings.meetPetSpeciesPrompt: "Escolha a espécie do seu companheiro",
      AppStrings.meetPetContinue: "Vamos começar!",
      AppStrings.meetPetPreviewTitle: "O que vamos fazer juntos",
      AppStrings.meetPetPreviewCelebrate:
          "Comemorar cada conquista da sua jornada",
      AppStrings.meetPetPreviewLearn:
          "Aprender sobre investimentos no seu ritmo",
      AppStrings.meetPetPreviewRemember:
          "Lembrar dos momentos importantes da nossa jornada",

      AppStrings.namePetTitle: "Escolha o Nome do seu Pet",
      AppStrings.namePetPrompt: "Como você gostaria de chamar seu companheiro?",
      AppStrings.namePetHint: "Nome do companheiro",
      AppStrings.namePetContinue: "Continuar",
      AppStrings.namePetReaction:
          "Adorei meu novo nome! Vamos começar sua jornada!",
      AppStrings.namePetRequiredError: "Escolha um nome para continuar",

      AppStrings.financialGoalTitle: "Qual será sua primeira missão?",
      AppStrings.financialGoalSubtitle:
          "Escolha o que você quer alcançar. Você pode mudar isso depois.",
      AppStrings.financialGoalContinue: "Continuar",

      AppStrings.onboardingSkip: "Pular",
      AppStrings.onboardingNext: "Próximo",

      AppStrings.welcomeHeadline: "Sua jornada financeira começa aqui.",
      AppStrings.welcomeSubheadline: "Aprenda. Invista. Evolua.",
      AppStrings.welcomeBody:
          "Transforme conhecimento financeiro em progresso de verdade.",
      AppStrings.welcomeCta: "Começar",

      AppStrings.academyIntroTitle: "Aprenda no seu ritmo.",
      AppStrings.academyIntroSubtitle: "Conhecimento antes de investir.",
      AppStrings.academyIntroBody:
          "Lições curtas, desafios e quizzes para você realmente entender de investimentos.",
      AppStrings.academyIntroXpBadge: "+{xp} XP por lição concluída",

      AppStrings.gamificationIntroTitle: "Aprenda. Jogue. Evolua.",
      AppStrings.gamificationIntroSubtitle:
          "Transforme conhecimento em progresso.",
      AppStrings.onboardingLevelBadge: "Nível {level}",

      AppStrings.missionCompleteLabel: "Missão Concluída",
      AppStrings.missionCompoundInterestTitle: "Aprenda sobre juros compostos",

      AppStrings.timeHorizonTitle: "Quando você quer alcançar isso?",
      AppStrings.timeHorizonSubtitle:
          "Isso ajusta o ritmo da sua jornada — você pode mudar depois.",

      AppStrings.journeyReadyTitle: "Sua jornada está pronta.",
      AppStrings.journeyReadySubtitle: "Agora é hora de começar a evoluir.",
      AppStrings.journeyReadyGoalLabel: "Seu objetivo",
      AppStrings.journeyReadyPathLabel: "Seu caminho",
      AppStrings.journeyReadyPathValue: "Aprender a Investir",
      AppStrings.journeyReadyCompanionLabel: "Seu companheiro",
      AppStrings.journeyReadyProgressLabel: "Seu progresso",
      AppStrings.journeyReadyFirstMissionLabel: "Sua primeira missão",
      AppStrings.journeyReadyCta: "Iniciar Minha Jornada",

      AppStrings.portfolioChoiceTitle: "Comece pelo conhecimento.",
      AppStrings.portfolioChoiceBody:
          "Você não precisa ter investimentos para começar sua jornada. Aprenda no seu ritmo e invista quando se sentir preparado.",
      AppStrings.portfolioChoiceFootnote:
          "Sem pressa — {petName} vai estar aqui em cada etapa.",
      AppStrings.portfolioGuidanceLearnTitle: "Aprenda antes de investir",
      AppStrings.portfolioGuidanceLearnBody:
          "Explore as lições e entenda como tomar decisões mais conscientes antes de aplicar seu dinheiro.",
      AppStrings.portfolioGuidancePortfolioTitle:
          "Sua carteira entra quando fizer sentido",
      AppStrings.portfolioGuidancePortfolioBody:
          "Quando você começar a investir, registre seus ativos aqui para acompanhar sua evolução.",
      AppStrings.portfolioGuidanceMentorTitle: "Conte com seu mentor",
      AppStrings.portfolioGuidanceMentorBody:
          "Com sua carteira cadastrada, o mentor poderá analisar seu progresso e ajudar você a aprender.",
      AppStrings.portfolioGuidanceContinueButton: "Começar a aprender",
      AppStrings.importPortfolioButton: "Importar Portfólio",
      AppStrings.addManuallyButton: "Adicionar Manualmente",
      AppStrings.skipForNowButton: "Pular por Enquanto",
      AppStrings.importComingSoonBody:
          "A importação automática (B3, corretoras, CSV) ainda está sendo construída. Por enquanto, você pode adicionar seus ativos manualmente ou pular esta etapa.",
      AppStrings.portfolioActivationIntroTitle: "Sua carteira começa aqui.",
      AppStrings.portfolioActivationIntroBody:
          "Acompanhe seus investimentos, entenda sua evolução e transforme conhecimento em decisões mais conscientes.",
      AppStrings.portfolioActivationStartButton: "Vamos começar",
      AppStrings.portfolioActivationStatusQuestion: "Você já investe?",
      AppStrings.portfolioActivationStatusYes: "Sim, já invisto",
      AppStrings.portfolioActivationStatusNo: "Ainda não",
      AppStrings.portfolioActivationConnectTitle:
          "Vamos adicionar seu primeiro investimento.",
      AppStrings.portfolioActivationConnectBody:
          "Registre seus ativos para começar a acompanhar sua carteira.",
      AppStrings.portfolioActivationAddFirstAssetButton:
          "Adicionar meu primeiro ativo",
      AppStrings.portfolioActivationLearnTitle:
          "Tudo bem. Você pode começar aprendendo.",
      AppStrings.portfolioActivationLearnBody:
          "Você não precisa ter investimentos para começar sua jornada como investidor.",
      AppStrings.portfolioActivationStartAcademyButton: "Começar pela Academia",
      AppStrings.portfolioActivationExploreJourneyButton:
          "Explorar minha jornada",
      AppStrings.portfolioActivationReturningNudge:
          "Ainda não adicionou seu primeiro investimento. Quando estiver pronto, podemos começar.",
      AppStrings.portfolioActivationReturningAddAsset: "Adicionar ativo",
      AppStrings.portfolioActivationReturningGoAcademy: "Ir para Academia",

      AppStrings.portfolioNotConnectedTitle: "Portfólio ainda não conectado",
      AppStrings.portfolioNotConnectedBody:
          "Conecte seus investimentos quando estiver pronto — sem pressa.",
      AppStrings.connectInvestmentsButton: "Conectar Investimentos",
      AppStrings.suggestedActionsTitle: "O que fazer agora",
      AppStrings.suggestedActionCompleteLesson: "Concluir sua primeira lição",
      AppStrings.suggestedActionTodayMission: "Concluir a missão de hoje",
      AppStrings.suggestedActionLearnDividends: "Aprender sobre dividendos",
      AppStrings.suggestedActionFirstQuiz: "Fazer seu primeiro quiz",
      AppStrings.suggestedActionInvestorProfile:
          "Completar seu perfil de investidor",
      AppStrings.comingSoonSnack: "Em construção — em breve!",

      AppStrings.portfolioReminderMessage:
          "Percebi que ainda não conectamos seus investimentos. Quando você quiser, posso analisar seu portfólio e criar missões personalizadas. Não há pressa.",
      AppStrings.portfolioReminderCta: "Conectar agora",
      AppStrings.portfolioReminderDismiss: "Agora não",

      AppStrings.companionSectionTitle: "Companheiro",
      AppStrings.renamePetLabel: "Nome do companheiro",
      AppStrings.renamePetButton: "Renomear",
      AppStrings.renamePetDialogTitle: "Renomear companheiro",
      AppStrings.renamePetSuccess: "Nome atualizado!",

      AppStrings.settingsTitle: "Configurações",
      AppStrings.settingsSubtitle: "Personalize sua experiência, Comandante.",
      AppStrings.languageSectionTitle: "Idioma",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Idioma atualizado",
      AppStrings.appearanceSectionTitle: "Aparência",
      AppStrings.appearanceLightLabel: "Claro",
      AppStrings.appearanceLightDescription: "Brilhante, limpo e acolhedor",
      AppStrings.appearanceDarkLabel: "Escuro",
      AppStrings.appearanceDarkDescription: "Premium, imersivo e futurista",
      AppStrings.appearanceSystemLabel: "Sistema",
      AppStrings.appearanceSystemDescription:
          "Segue as configurações do aparelho",
      AppStrings.appearanceUpdated: "Aparência atualizada",
      AppStrings.notificationsSectionTitle: "Notificações",
      AppStrings.dailyMissionReminders: "Lembretes de missões diárias",
      AppStrings.achievementAlerts: "Alertas de conquistas",
      AppStrings.privacySectionTitle: "Privacidade",
      AppStrings.showOnRankings: "Aparecer nos rankings",
      AppStrings.accountSectionTitle: "Conta",
      AppStrings.logoutButton: "Sair",
      AppStrings.logoutConfirmTitle: "Sair do Invest Game?",
      AppStrings.logoutConfirmMessage:
          "Tem certeza que deseja encerrar sua sessão?",
      AppStrings.cancelButton: "Cancelar",

      AppStrings.levelUpAchieved: "Nível {level} alcançado!",

      AppStrings.shareProgressLevelLabel: "Nível {level}",
      AppStrings.shareProgressXpTotalLabel: "{xp} XP totais",
      AppStrings.shareProgressXpToNextLabel:
          "{current}/{total} XP para o próximo nível",
      AppStrings.shareProgressLevelUpBadge: "Subiu de nível!",
      AppStrings.shareProgressTagline:
          "Evoluindo rumo à liberdade financeira 🚀",
      AppStrings.shareProgressCta: "Baixe o Invest Game e comece sua jornada",
      AppStrings.shareProgressButton: "Compartilhar",
      AppStrings.shareProgressContinueButton: "Continuar",
      AppStrings.shareProgressErrorMessage:
          "Não foi possível compartilhar agora. Tente novamente.",
      AppStrings.academyModuleShareTitle: "Módulo concluído!",

      AppStrings.academyLevelLabel: "Investidor Nível {level}",
      AppStrings.academyXpEarnedLabel: "{xp} XP conquistados na Academia",
      AppStrings.academyContinueSectionLabel: "CONTINUAR",
      AppStrings.academyXpToCompleteLabel: "+{xp} XP ao concluir",
      AppStrings.academyStartLessonButton: "Começar Lição",
      AppStrings.academyModulesSectionLabel: "MÓDULOS",
      AppStrings.academyLessonsSectionLabel: "LIÇÕES",
      AppStrings.academyLessonsProgressLabel: "{completed} / {total} lições",
      AppStrings.academyLessonCompleteTitle: "Lição Concluída!",
      AppStrings.academyXpPill: "+{xp} XP",
      AppStrings.academyContinueButton: "Continuar",
      AppStrings.academyConcludeButton: "Concluir",
      AppStrings.academyBackToAcademyButton: "Voltar à Academia",
      AppStrings.academyModuleStatusCompleted: "MÓDULO CONCLUÍDO",
      AppStrings.academyModuleStatusInProgress: "EM ANDAMENTO",
      AppStrings.academyModuleStatusAvailable: "DISPONÍVEL",
      AppStrings.academyModuleStatusComingSoon: "EM BREVE",
      AppStrings.academyModuleStatusLocked: "BLOQUEADO",
      AppStrings.academyLockedPrerequisiteLabel: "Conclua {name} primeiro",
      AppStrings.academySchoolsSectionLabel: "TRILHA",
      AppStrings.academyDomainsSectionLabel: "ESCOLAS",
      AppStrings.academyCatalogErrorTitle:
          "Não foi possível carregar a Academia",
      AppStrings.academyCatalogErrorBody:
          "Verifique sua conexão e tente novamente.",
      AppStrings.academyMasterySectionLabel: "SUA MAESTRIA",
      AppStrings.academyMasteryPercentLabel: "{percent}% concluído",
      AppStrings.academyKnowledgeLevelLabel:
          "Progresso de conhecimento: {tier}",
      AppStrings.academyMicroExerciseLabel: "EXERCÍCIO RÁPIDO",
      AppStrings.academyApplyLabel: "APLIQUE O QUE APRENDEU",
      AppStrings.academyCorrectFeedbackTitle: "Isso mesmo!",
      AppStrings.academyIncorrectFeedbackTitle: "Quase! Vamos entender:",
      AppStrings.academyCorrectFeedbackTitle2: "Isso! Você entendeu.",
      AppStrings.academyCorrectFeedbackTitle3: "Boa, você acertou essa!",
      AppStrings.academyIncorrectFeedbackTitle2:
          "Quase. Essa parte costuma confundir mesmo.",
      AppStrings.academyIncorrectFeedbackTitle3:
          "Não foi dessa vez. Vamos ver com calma:",

      AppStrings.academyProgressLabel: "Progresso",
      AppStrings.academyRealMasteryLabel: "Maestria",
      AppStrings.masteryTierExploring: "Explorando",
      AppStrings.masteryTierUnderstanding: "Entendendo",
      AppStrings.masteryTierApplying: "Aplicando",
      AppStrings.masteryTierMastering: "Dominando",

      AppStrings.academyRecommendedSectionLabel: "RECOMENDADO PARA VOCÊ",
      AppStrings.academyRecommendationContinueReason:
          "O próximo passo da sua jornada",
      AppStrings.academyRecommendationReviewReason:
          "Você errou uma pergunta aqui — vale revisar",
      AppStrings.academyReviewCardTitle: "Revisão de hoje",
      AppStrings.academyReviewCardSubtitle: "{count} lições · ~{minutes} min",
      AppStrings.academyReviewStartButton: "Começar revisão",
      AppStrings.academyReviewEmptyState:
          "Tudo em dia — nada para revisar agora.",

      AppStrings.financialLabSectionLabel: "LABORATÓRIO FINANCEIRO",
      AppStrings.financialLabTitle: "Laboratório Financeiro",
      AppStrings.financialLabSubtitle:
          "Simule cenários e veja os conceitos em ação.",
      AppStrings.labCompoundInterestTitle: "Juros Compostos",
      AppStrings.labCompoundInterestSubtitle:
          "Veja como aporte, prazo e taxa mudam o resultado.",
      AppStrings.labComingSoon: "Em breve",
      AppStrings.labInflationTitle: "Inflação",
      AppStrings.labFixedIncomeTitle: "Renda Fixa",
      AppStrings.labDiversificationTitle: "Diversificação",
      AppStrings.labPortfolioTitle: "Carteira",
      AppStrings.labInitialAmountLabel: "Valor inicial",
      AppStrings.labMonthlyContributionLabel: "Aporte mensal",
      AppStrings.labAnnualReturnLabel: "Retorno anual",
      AppStrings.labYearsLabel: "Anos",
      AppStrings.labFinalValueLabel: "Valor final",
      AppStrings.labTotalContributionsLabel: "Total investido",
      AppStrings.labTotalGrowthLabel: "Total em rendimentos",
      AppStrings.labExplanationIncreaseYears:
          "Aumentar o prazo de {from} para {to} anos ampliou bastante o efeito dos juros compostos sobre o resultado.",
      AppStrings.labExplanationDecreaseYears:
          "Reduzir o prazo de {from} para {to} anos deu menos tempo para os juros compostos atuarem.",
      AppStrings.labExplanationIncreaseReturn:
          "Aumentar o retorno anual de {from}% para {to}% acelerou o crescimento do seu dinheiro ao longo do tempo.",
      AppStrings.labExplanationDecreaseReturn:
          "Reduzir o retorno anual de {from}% para {to}% desacelerou o crescimento do seu dinheiro ao longo do tempo.",
      AppStrings.labExplanationInitial:
          "Ajuste os valores para ver como cada variável muda o resultado final.",
      AppStrings.labYearTooltipLabel: "Ano {year}",
      AppStrings.labDataTableDisclosureTitle: "Ver os números em texto",
      AppStrings.labExplanationIncreaseInitial:
          "Aumentar o valor inicial de {from} para {to} deu um empurrão maior no ponto de partida do seu dinheiro.",
      AppStrings.labExplanationDecreaseInitial:
          "Reduzir o valor inicial de {from} para {to} deu um ponto de partida menor para os juros compostos trabalharem.",
      AppStrings.labExplanationIncreaseContribution:
          "Aumentar o aporte mensal de {from} para {to} acelera o crescimento porque mais dinheiro entra todo mês.",
      AppStrings.labExplanationDecreaseContribution:
          "Reduzir o aporte mensal de {from} para {to} deixa o crescimento mais dependente dos juros compostos sozinhos.",
      AppStrings.labCompoundInterestIntro:
          "Ajuste valor inicial, aporte mensal, retorno e prazo para ver como os juros compostos fazem seu dinheiro crescer.",
      AppStrings.labCompoundInterestInterpretation:
          "Repare como o crescimento (a parte dourada da barra) fica proporcionalmente maior quanto mais tempo o dinheiro fica investido.",
      AppStrings.labCompleteButton: "Concluir simulação",
      AppStrings.labCompletedLabel: "Concluído",
      AppStrings.labCompoundInterestQuestion:
          "Se você deixar o mesmo dinheiro investido por mais tempo, mantendo a mesma taxa, o que tende a acontecer com os juros ganhos?",
      AppStrings.labCompoundInterestOptionA: "Eles diminuem com o tempo",
      AppStrings.labCompoundInterestOptionB:
          "Eles crescem proporcionalmente mais rápido",
      AppStrings.labCompoundInterestOptionC: "Eles ficam sempre iguais",
      AppStrings.labCompoundInterestAnswerExplanation:
          "Nos juros compostos, você ganha juros sobre os juros já ganhos antes — por isso o crescimento acelera quanto mais tempo o dinheiro fica investido.",
      AppStrings.labInflationSubtitle:
          "Veja como a inflação corrói o poder de compra do seu dinheiro.",
      AppStrings.labInflationRateLabel: "Inflação anual",
      AppStrings.labInflationRealValueLabel: "Poder de compra real",
      AppStrings.labInflationNominalValueLabel: "Valor nominal",
      AppStrings.labInflationLostPercentLabel: "Poder de compra perdido",
      AppStrings.labInflationBasketMultiplierLabel: "Custa hoje",
      AppStrings.labInflationIntro:
          "Ajuste o valor inicial, a inflação e os anos para ver como o mesmo dinheiro compra cada vez menos com o tempo.",
      AppStrings.labInflationInterpretation:
          "Com {rate}% de inflação ao ano, o mesmo valor perde {lostPercent}% do seu poder de compra em {years} anos — a mesma cesta de produtos passa a custar {multiplier} o preço de hoje.",
      AppStrings.labInflationInvestingConnection:
          "Retorno real exato: ({nominal} + 1) ÷ ({inflation} + 1) − 1 = {exact}%. A aproximação comum \"retorno nominal − inflação\" dá {approx}% — próxima, mas não exata.",
      AppStrings.labInflationQuestion:
          "Se a inflação ficar acima do retorno do seu investimento por vários anos, o que acontece com o seu poder de compra?",
      AppStrings.labInflationOptionA: "Ele aumenta",
      AppStrings.labInflationOptionB: "Ele diminui",
      AppStrings.labInflationOptionC: "Ele permanece o mesmo",
      AppStrings.labInflationAnswerExplanation:
          "Quando a inflação supera o retorno nominal, o retorno real fica negativo — seu dinheiro cresce em número, mas compra cada vez menos.",
      AppStrings.labFixedIncomeSubtitle:
          "Veja como taxa, prazo e aportes fazem sua renda fixa crescer.",
      AppStrings.labFixedIncomePrincipalLabel: "Principal investido",
      AppStrings.labFixedIncomeInterestLabel: "Juros acumulados",
      AppStrings.labFixedIncomeNominalRateLabel: "Taxa nominal",
      AppStrings.labFixedIncomeEffectiveRateLabel: "Taxa efetiva anual",
      AppStrings.labFixedIncomeGrossDisclaimer:
          "Valores brutos — impostos e taxas variam por produto (CDB, LCI, LCA, Tesouro) e não estão incluídos aqui.",
      AppStrings.labFixedIncomeIntro:
          "Ajuste valor inicial, aporte mensal, taxa e prazo para ver como sua renda fixa evolui — e como a taxa efetiva supera a nominal graças à capitalização mensal.",
      AppStrings.labFixedIncomeInterpretation:
          "Com {years} anos investidos, os juros já representam {interestShare}% do valor final — quanto mais tempo o dinheiro fica aplicado, maior essa fatia.",
      AppStrings.labFixedIncomeQuestion:
          "Se o prazo do investimento aumenta, mantendo a mesma taxa, o que tende a acontecer com a parcela de juros no valor final?",
      AppStrings.labFixedIncomeOptionA: "Ela diminui",
      AppStrings.labFixedIncomeOptionB: "Ela aumenta",
      AppStrings.labFixedIncomeOptionC: "Ela desaparece",
      AppStrings.labFixedIncomeAnswerExplanation:
          "Quanto mais tempo o dinheiro fica investido, mais os juros têm chance de compor sobre juros anteriores — por isso a parcela de juros cresce com o prazo.",
      AppStrings.labInvestmentTypeStocks: "Ações",
      AppStrings.labInvestmentTypeFixedIncome: "Renda Fixa",
      AppStrings.labInvestmentTypeRealEstate: "Fundos Imobiliários",
      AppStrings.labInvestmentTypeCrypto: "Cripto",
      AppStrings.labInvestmentTypeFunds: "ETFs & Fundos",
      AppStrings.labInvestmentTypeOthers: "Outros",
      AppStrings.labAllocationTotalLabel: "Total alocado",
      AppStrings.labAllocationHint: "A alocação deve somar 100%.",
      AppStrings.labDiversificationSubtitle:
          "Monte uma carteira e veja como a concentração afeta o risco.",
      AppStrings.labDiversificationScoreLabel: "Índice de diversificação",
      AppStrings.labDiversificationEffectiveAssetsLabel:
          "Equivale a quantos ativos",
      AppStrings.labDiversificationConcentrationLabel: "Maior posição",
      AppStrings.labDiversificationIntro:
          "Distribua 100% entre as categorias e veja como a concentração muda o risco da sua carteira simulada.",
      AppStrings.labDiversificationInterpretation:
          "Sua maior posição, {category}, representa {largestWeight}% da carteira — isso é como ter apenas {effectiveAssets} ativos igualmente distribuídos.",
      AppStrings.labDiversificationConcentrationShockButton:
          "Maior posição cai 30%",
      AppStrings.labDiversificationMarketShockButton: "Tudo cai 15%",
      AppStrings.labDiversificationConcentrationShockResult:
          "Se {category} caísse 30%, sua carteira perderia {impact}% do valor total — quanto maior a posição, maior o estrago.",
      AppStrings.labDiversificationMarketShockResult:
          "Se todas as categorias caíssem 15% ao mesmo tempo, sua carteira perderia 15% — esse número é sempre o mesmo, não importa como você distribuiu o dinheiro.",
      AppStrings.labDiversificationSafetyDisclaimer:
          "Diversificar reduz o risco de concentração em um único ativo, mas não elimina o risco do mercado como um todo — carteira diversificada não é sinônimo de carteira sem risco.",
      AppStrings.labDiversificationQuestion: "Diversificar protege contra…",
      AppStrings.labDiversificationOptionA:
          "Risco de concentração em um único ativo",
      AppStrings.labDiversificationOptionB: "Qualquer queda do mercado",
      AppStrings.labDiversificationOptionC: "Todas as perdas possíveis",
      AppStrings.labDiversificationAnswerExplanation:
          "Diversificação reduz o quanto uma única posição pode te machucar, mas quando o mercado inteiro cai, uma carteira diversificada também sente o impacto.",
      AppStrings.labPortfolioSubtitle:
          "Monte uma carteira hipotética e teste cenários de mercado.",
      AppStrings.labPortfolioTotalAmountLabel: "Valor total simulado",
      AppStrings.labPortfolioNewValueLabel: "Valor após o cenário",
      AppStrings.labPortfolioDeltaLabel: "Variação",
      AppStrings.labPortfolioIntro:
          "Monte uma carteira hipotética, escolha um cenário e veja como a composição muda a resposta da carteira — sem afetar sua carteira real.",
      AppStrings.labPortfolioSandboxDisclaimer:
          "Esta é uma carteira hipotética de laboratório — nada aqui afeta sua Carteira real.",
      AppStrings.labPortfolioForecastDisclaimer:
          "Estes cenários são simulações educacionais e não preveem retornos futuros.",
      AppStrings.labPortfolioScenarioEquitiesDown15: "Ações caem 15%",
      AppStrings.labPortfolioScenarioLargestPositionDown20:
          "Maior posição cai 20%",
      AppStrings.labPortfolioScenarioBroadMarketDown10: "Tudo cai 10%",
      AppStrings.labPortfolioScenarioFixedIncomeUp5: "Renda Fixa sobe 5%",
      AppStrings.labPortfolioScenarioResult:
          "Neste cenário, sua carteira simulada mudaria {deltaPercent}%, de {before} para {after} — a carteira reage diferente de cada ativo isolado.",
      AppStrings.labPortfolioQuestion:
          "Por que o impacto de um cenário na carteira inteira costuma ser diferente do impacto em um único ativo?",
      AppStrings.labPortfolioOptionA:
          "Porque a carteira combina ativos com pesos diferentes",
      AppStrings.labPortfolioOptionB:
          "Porque todos os ativos sempre se movem juntos",
      AppStrings.labPortfolioOptionC: "Porque a carteira ignora os cenários",
      AppStrings.labPortfolioAnswerExplanation:
          "O impacto total é a soma ponderada do impacto em cada categoria — por isso a carteira como um todo reage de um jeito que nenhum ativo isolado reflete sozinho.",

      AppStrings.appBarPlayerNamedGreeting: "{petName} · Nível {level}",
      AppStrings.appBarPlayerGenericGreeting: "Nível {level} · Explorador",
      AppStrings.profileTooltip: "Perfil",
      AppStrings.notificationsTooltip: "Notificações",
      AppStrings.logoutTooltip: "Sair",
      AppStrings.navHome: "Início",
      AppStrings.navWallet: "Carteira",
      AppStrings.navPassiveIncome: "Proventos",
      AppStrings.navAcademy: "Academia",
      AppStrings.navMentor: "Mentor",
      AppStrings.homeContinueLearningEyebrow: "Missão de hoje",
      AppStrings.homeContinueLearningCta: "Continuar Aprendendo",
      AppStrings.homeAllLessonsCompleteTitle: "Você concluiu tudo por aqui!",
      AppStrings.homeAllLessonsCompleteBody:
          "Novos módulos chegam em breve. Explore a Academia para revisar o que já aprendeu.",
      AppStrings.homeExploreAcademyCta: "Ver Academia",
      AppStrings.homeLevelProgressLabel: "XP para o próximo nível",
      AppStrings.homeNextEvolutionLabel: "XP para a próxima evolução",
      AppStrings.homeMaxEvolutionLabel: "Evolução máxima alcançada",
      AppStrings.homeKnowledgeMapLabel: "SUA TRILHA DE CONHECIMENTO",
      AppStrings.homeViewFullAcademyCta: "Ver trilha completa",
      AppStrings.homePortfolioBridgeLabel: "SUA CARTEIRA",
      AppStrings.homePortfolioBridgeApplyMessage:
          "Você já concluiu {count} lições — veja como aplicar esse conhecimento na sua carteira real.",
      AppStrings.homeViewPortfolioCta: "Ver Carteira",
      AppStrings.homeAnswerInvestorProfileLink:
          "Ainda não respondeu seu perfil de risco? Responder agora",
      AppStrings.homeMissionAlmostDoneEyebrow: "Quase lá",
      AppStrings.homeMissionAlmostDoneBody:
          "Falta 1 aula para completar essa missão e ganhar +{xp} XP.",
      AppStrings.levelTierBeginner: "Iniciante",
      AppStrings.levelTierLearner: "Aprendiz",
      AppStrings.levelTierExplorer: "Explorador",
      AppStrings.levelTierInvestor: "Investidor",
      AppStrings.levelTierAnalyst: "Analista",
      AppStrings.levelTierStrategist: "Estrategista",
      AppStrings.levelTierSpecialist: "Especialista",

      // Knowledge Progress tiers (curriculum completion, not XP)
      AppStrings.knowledgeLevelAbsoluteBeginner: "Iniciante Absoluto",
      AppStrings.knowledgeLevelFinancialApprentice: "Aprendiz Financeiro",
      AppStrings.knowledgeLevelFinancialOrganizer: "Organizador Financeiro",
      AppStrings.knowledgeLevelFinancialProtector: "Protetor Financeiro",
      AppStrings.knowledgeLevelBeginnerInvestor: "Investidor Iniciante",
      AppStrings.knowledgeLevelInvestor: "Investidor",
      AppStrings.knowledgeLevelAnalyst: "Analista",
      AppStrings.knowledgeLevelWealthBuilder: "Construtor de Patrimônio",
      AppStrings.knowledgeLevelFinancialStrategist: "Estrategista Financeiro",
      AppStrings.knowledgeLevelFinancialMaster: "Mestre Financeiro",

      AppStrings.companionHeaderTooltip: "Abrir seu companheiro",
      AppStrings.companionDismissTooltip: "Fechar",
      AppStrings.companionInteractionTitle: "Como posso ajudar?",
      AppStrings.companionInteractionSubtitle: "Escolha para onde ir",
      AppStrings.companionInteractionLearn: "Aprender",
      AppStrings.companionInteractionPortfolio: "Carteira",
      AppStrings.companionInteractionProgress: "Progresso",
      AppStrings.companionActionContinue: "Continuar",
      AppStrings.companionActionViewPortfolio: "Ver Carteira",
      AppStrings.companionActionViewProgress: "Ver Progresso",
      AppStrings.companionHomeXpToNextLevel:
          "Faltam {xp} XP para o próximo nível!",
      AppStrings.companionAcademyContinueLesson:
          "Você estava progredindo em \"{lessonTitle}\". Continuar de onde parou?",
      AppStrings.companionAcademyReviewDue:
          "Você tem {count} conceitos para revisar. Vamos reforçar o que já aprendeu?",
      AppStrings.companionPortfolioDiversified:
          "Sua carteira está distribuída em {count} ativos diferentes.",
      AppStrings.companionMentorNudge:
          "Tem alguma dúvida sobre investimentos? Pergunte para mim.",
      AppStrings.companionProfileSummary:
          "Você está no nível {level} — {stage}.",
      AppStrings.companionEventLessonCompleted:
          "Muito bem! Você concluiu a lição.",
      AppStrings.companionEventXpGained: "+{xp} XP! Continue assim.",
      AppStrings.companionEventLevelUp:
          "Nível {level} alcançado! Estou orgulhoso de você.",
      AppStrings.companionEventAchievementUnlocked:
          "Conquista desbloqueada: {title}!",
      AppStrings.companionEventEvolved: "Eu evoluí! Agora sou {stage}.",
      AppStrings.companionEventDifficultyDetected:
          "Notei que você errou algumas em {school}. Que tal revisar juntos?",
      AppStrings.companionEventSchoolMastered:
          "Você concluiu tudo disponível em {school}! Muito bem!",
      AppStrings.companionEventFirstInvestment:
          "Esse foi seu primeiro investimento! Vamos entender melhor o que você acabou de adicionar à sua carteira?",
      AppStrings.companionEventHighConcentration:
          "Percebi que {ticker} representa {percent}% da sua carteira. Quer entender por que diversificar pode reduzir o risco?",
      AppStrings.companionPortfolioActivationNudge:
          "Toda jornada de investidor começa com o primeiro passo. Estou aqui quando você quiser dar o seu.",
      AppStrings.companionInvestorStatusYes:
          "Ótimo! Vamos começar registrando seu primeiro investimento.",
      AppStrings.companionInvestorStatusNo:
          "Sem problema! Você não precisa ter investimentos para começar sua jornada.",
      AppStrings.companionActionUnderstand: "Entender",
      AppStrings.companionHomeMotivation1:
          "Cada pequeno passo te deixa mais preparado para o futuro. Continue assim!",
      AppStrings.companionHomeMotivation2:
          "Investir é uma maratona, não uma corrida. Sua consistência já é uma conquista.",
      AppStrings.companionHomeMotivation3:
          "Você está construindo um hábito que vai valer a pena. Tenho orgulho de te acompanhar nessa jornada.",
      AppStrings.companionHomeMotivation4:
          "Aprender sobre dinheiro é um dos melhores investimentos que você pode fazer. Bora continuar?",
      AppStrings.companionHomeMotivation5:
          "Cada dia que você volta aqui é um dia mais perto dos seus objetivos.",
      AppStrings.companionHomeReturnGreeting1:
          "Bom te ver de novo! Vamos continuar de onde paramos?",
      AppStrings.companionHomeReturnGreeting2:
          "Que bom que voltou! Sua jornada continua esperando por você.",
      AppStrings.companionHomeMissionAlmostDone:
          "Você está a uma aula de completar '{missionTitle}'!",
      AppStrings.companionEventMissionCompleted:
          "Missão completa: {title}! Mais um passo rumo a um investidor mais confiante.",
      AppStrings.companionEventLabSimulatorCompleted:
          "Você concluiu o simulador de {simulator}! Isso é entender investimentos na prática.",

      AppStrings.forgotPasswordTitle: "Recuperar senha",
      AppStrings.forgotPasswordSubtitle:
          "Digite seu e-mail e enviaremos um link para redefinir sua senha.",
      AppStrings.forgotPasswordEmailHint: "Seu e-mail",
      AppStrings.forgotPasswordSendButton: "Enviar link",
      AppStrings.forgotPasswordConfirmationMessage:
          "Se existir uma conta com esse e-mail, você receberá instruções em instantes.",
      AppStrings.forgotPasswordHaveCodeLink:
          "Já tenho um código de redefinição",
      AppStrings.resetPasswordTitle: "Redefinir senha",
      AppStrings.resetPasswordSubtitle:
          "Cole o código que enviamos por e-mail e escolha uma nova senha.",
      AppStrings.resetPasswordTokenHint: "Código de redefinição",
      AppStrings.resetPasswordNewPasswordHint: "Nova senha",
      AppStrings.resetPasswordSubmitButton: "Redefinir senha",
      AppStrings.resetPasswordSuccessMessage:
          "Senha redefinida com sucesso! Faça login com sua nova senha.",
      AppStrings.resetPasswordMismatchError: "As senhas não coincidem.",
      AppStrings.resetPasswordFieldsRequiredError: "Preencha todos os campos.",

      AppStrings.wealthLegendPatrimony: "Patrimônio",
      AppStrings.wealthLegendInvested: "Investido",
      AppStrings.wealthLegendAppliedValue: "Valor aplicado",
      AppStrings.wealthLegendCapitalGain: "Ganho de Capital",
      AppStrings.proventosLegendReceived: "Recebidos",
      AppStrings.proventosLegendExpected: "A receber",
      AppStrings.noAssetsRegisteredYet: "Nenhum ativo registrado ainda.",
      AppStrings.retryButtonLabel: "Tentar novamente",
      AppStrings.errorNoConnectionMessage:
          "Não foi possível conectar. Verifique sua internet e tente novamente.",
      AppStrings.errorUnexpectedMessage:
          "Algo inesperado aconteceu. Tente novamente.",
      AppStrings.mentorNewChatTooltip: "Nova conversa",
      AppStrings.mentorHistoryTooltip: "Histórico",
      AppStrings.mentorConversationHistoryTitle: "Conversas",
      AppStrings.mentorNoConversationsTitle: "Nenhuma conversa ainda",
      AppStrings.mentorNoConversationsSubtitle:
          "Suas conversas com o mentor vão aparecer aqui.",
      AppStrings.mentorConversationsLoadError:
          "Não foi possível carregar suas conversas.",
      AppStrings.mentorRenameConversationTitle: "Renomear conversa",
      AppStrings.mentorRenameConversationHint: "Título da conversa",
      AppStrings.mentorRenameConversationSave: "Salvar",
      AppStrings.mentorRenameConversationFailed:
          "Não foi possível renomear a conversa. Tente novamente.",
      AppStrings.mentorDeleteConversationTitle: "Apagar conversa?",
      AppStrings.mentorDeleteConversationConfirm:
          "Esta conversa e todas as mensagens serão apagadas permanentemente.",
      AppStrings.mentorDeleteConversationButton: "Apagar",
      AppStrings.mentorDeleteConversationFailed:
          "Não foi possível apagar a conversa. Tente novamente.",
      AppStrings.initialPortfolioTitle: "Portfólio Inicial",
      AppStrings.portfolioCardTitle: "Portfólio",
      AppStrings.profileTitle: "Perfil",
      AppStrings.profileCommanderTitle: "Perfil do Comandante",
      AppStrings.profileAchievementsLabel: "Conquistas",
      AppStrings.profileAchievementsComingSoonBody:
          "Suas conquistas e marcos vão aparecer aqui conforme você progride.",
      AppStrings.profileSettingsHint:
          "Gerencie idioma e conta nas configurações.",
      AppStrings.investorProfileScreenTitle: "Perfil de Risco",
      AppStrings.investorProfileScreenSubtitle:
          "Diferente do seu objetivo financeiro — isto é sobre como você lida com risco.",
      AppStrings.investorProfileClearAnswersButton: "Limpar respostas",
      AppStrings.investorProfileClearAnswers: "Respostas limpas.",
      AppStrings.petTeacherAskMentor: "Pergunte ao mentor:",
      AppStrings.petTeacherOwnedGreeting: "Vamos entender melhor {assetName}!",
      AppStrings.petTeacherNotOwnedGreeting:
          "Quer saber mais sobre {assetName}?",
    },
    'en': {
      AppStrings.welcomeBack: "Welcome back",
      AppStrings.loginToContinue: "Login to continue",
      AppStrings.emailOrUserHint: "Email or Username",
      AppStrings.passwordHint: "Password",
      AppStrings.forgotPassword: "Forgot password?",
      AppStrings.noAccountSignUp: "Don't have an account? Sign up",
      AppStrings.loginButton: "Login",
      AppStrings.continueWithGoogle: "Continue with Google",
      AppStrings.orDivider: "or",
      AppStrings.createAccount: "Create Account",
      AppStrings.fillDetails: "Fill in your details",
      AppStrings.nameHint: "Full Name",
      AppStrings.confirmPasswordHint: "Confirm Password",
      AppStrings.signupButton: "Sign Up",
      AppStrings.alreadyHaveAccount: "Already have an account? Login",

      AppStrings.pleaseAnswerAllQuestions: "Please answer all questions",
      AppStrings.onboardingFailed: "Failed to submit answers",
      AppStrings.noQuestionsAvailable: "No questions available.",
      AppStrings.failedToLoadQuestions: "Failed to load questions",

      AppStrings.petProfileTitle: "Pet Profile",
      AppStrings.failedToSavePet: "Failed to save pet",

      AppStrings.meetPetTitle: "Meet Your Companion",
      AppStrings.meetPetGreeting: "Hello!",
      AppStrings.meetPetIntro:
          "I'm your financial companion. I'll help you learn about investing, stay disciplined and celebrate every achievement along your journey.",
      AppStrings.meetPetNeedName: "But first... I need a name!",
      AppStrings.meetPetSpeciesPrompt: "Choose your companion's species",
      AppStrings.meetPetContinue: "Let's get started!",
      AppStrings.meetPetPreviewTitle: "What we'll do together",
      AppStrings.meetPetPreviewCelebrate:
          "Celebrate every milestone of your journey",
      AppStrings.meetPetPreviewLearn: "Learn about investing at your own pace",
      AppStrings.meetPetPreviewRemember:
          "Remember the important moments of our journey",

      AppStrings.namePetTitle: "Name Your Pet",
      AppStrings.namePetPrompt: "What would you like to call your companion?",
      AppStrings.namePetHint: "Companion's name",
      AppStrings.namePetContinue: "Continue",
      AppStrings.namePetReaction:
          "I love my new name! Let's start your journey!",
      AppStrings.namePetRequiredError: "Choose a name to continue",

      AppStrings.financialGoalTitle: "What will be your first mission?",
      AppStrings.financialGoalSubtitle:
          "Choose what you want to achieve. You can change it later.",
      AppStrings.financialGoalContinue: "Continue",

      AppStrings.onboardingSkip: "Skip",
      AppStrings.onboardingNext: "Next",

      AppStrings.welcomeHeadline: "Your financial journey starts here.",
      AppStrings.welcomeSubheadline: "Learn. Invest. Evolve.",
      AppStrings.welcomeBody: "Turn financial knowledge into real progress.",
      AppStrings.welcomeCta: "Start",

      AppStrings.academyIntroTitle: "Learn at your own pace.",
      AppStrings.academyIntroSubtitle: "Knowledge before investing.",
      AppStrings.academyIntroBody:
          "Short lessons, challenges, and quizzes designed to help you actually understand investing.",
      AppStrings.academyIntroXpBadge: "+{xp} XP per completed lesson",

      AppStrings.gamificationIntroTitle: "Learn. Play. Evolve.",
      AppStrings.gamificationIntroSubtitle: "Turn knowledge into progress.",
      AppStrings.onboardingLevelBadge: "Level {level}",

      AppStrings.missionCompleteLabel: "Mission Complete",
      AppStrings.missionCompoundInterestTitle: "Learn about compound interest",

      AppStrings.timeHorizonTitle: "When do you want to achieve it?",
      AppStrings.timeHorizonSubtitle:
          "This paces your journey — you can change it later.",

      AppStrings.journeyReadyTitle: "Your journey is ready.",
      AppStrings.journeyReadySubtitle: "Now it's time to start evolving.",
      AppStrings.journeyReadyGoalLabel: "Your goal",
      AppStrings.journeyReadyPathLabel: "Your path",
      AppStrings.journeyReadyPathValue: "Learn to Invest",
      AppStrings.journeyReadyCompanionLabel: "Your companion",
      AppStrings.journeyReadyProgressLabel: "Your progress",
      AppStrings.journeyReadyFirstMissionLabel: "Your first mission",
      AppStrings.journeyReadyCta: "Start My Journey",

      AppStrings.portfolioChoiceTitle: "Start with knowledge.",
      AppStrings.portfolioChoiceBody:
          "You don't need investments to begin your journey. Learn at your own pace and invest when you feel ready.",
      AppStrings.portfolioChoiceFootnote:
          "There's no rush — {petName} will be here at every step.",
      AppStrings.portfolioGuidanceLearnTitle: "Learn before you invest",
      AppStrings.portfolioGuidanceLearnBody:
          "Explore the lessons and understand how to make more informed decisions before putting your money to work.",
      AppStrings.portfolioGuidancePortfolioTitle:
          "Your portfolio can wait until it makes sense",
      AppStrings.portfolioGuidancePortfolioBody:
          "When you start investing, add your assets here to track your progress.",
      AppStrings.portfolioGuidanceMentorTitle: "Count on your mentor",
      AppStrings.portfolioGuidanceMentorBody:
          "With your portfolio registered, your mentor can analyze your progress and help you learn.",
      AppStrings.portfolioGuidanceContinueButton: "Start learning",
      AppStrings.importPortfolioButton: "Import Portfolio",
      AppStrings.addManuallyButton: "Add Manually",
      AppStrings.skipForNowButton: "Skip For Now",
      AppStrings.importComingSoonBody:
          "Automatic import (B3, brokers, CSV) is still being built. For now, you can add your assets manually or skip this step.",
      AppStrings.portfolioActivationIntroTitle: "Your portfolio starts here.",
      AppStrings.portfolioActivationIntroBody:
          "Track your investments, understand your progress, and turn knowledge into more confident decisions.",
      AppStrings.portfolioActivationStartButton: "Let's start",
      AppStrings.portfolioActivationStatusQuestion: "Do you already invest?",
      AppStrings.portfolioActivationStatusYes: "Yes, I already invest",
      AppStrings.portfolioActivationStatusNo: "Not yet",
      AppStrings.portfolioActivationConnectTitle:
          "Let's add your first investment.",
      AppStrings.portfolioActivationConnectBody:
          "Register your assets to start tracking your portfolio.",
      AppStrings.portfolioActivationAddFirstAssetButton: "Add my first asset",
      AppStrings.portfolioActivationLearnTitle:
          "That's okay. You can start by learning.",
      AppStrings.portfolioActivationLearnBody:
          "You don't need to have investments yet to start becoming a better investor.",
      AppStrings.portfolioActivationStartAcademyButton:
          "Start with the Academy",
      AppStrings.portfolioActivationExploreJourneyButton: "Explore my journey",
      AppStrings.portfolioActivationReturningNudge:
          "You haven't added your first investment yet. Whenever you're ready, we can start.",
      AppStrings.portfolioActivationReturningAddAsset: "Add asset",
      AppStrings.portfolioActivationReturningGoAcademy: "Go to Academy",

      AppStrings.portfolioNotConnectedTitle: "Portfolio not connected yet",
      AppStrings.portfolioNotConnectedBody:
          "Connect your investments whenever you're ready — no rush.",
      AppStrings.connectInvestmentsButton: "Connect Investments",
      AppStrings.suggestedActionsTitle: "What to do now",
      AppStrings.suggestedActionCompleteLesson: "Complete your first lesson",
      AppStrings.suggestedActionTodayMission: "Complete today's mission",
      AppStrings.suggestedActionLearnDividends: "Learn about dividends",
      AppStrings.suggestedActionFirstQuiz: "Start your first quiz",
      AppStrings.suggestedActionInvestorProfile:
          "Complete your investor profile",
      AppStrings.comingSoonSnack: "Coming soon!",

      AppStrings.portfolioReminderMessage:
          "I noticed we still haven't connected your investments. When you're ready, I can analyze your portfolio and create personalized missions. There is no rush.",
      AppStrings.portfolioReminderCta: "Connect now",
      AppStrings.portfolioReminderDismiss: "Not now",

      AppStrings.companionSectionTitle: "Companion",
      AppStrings.renamePetLabel: "Companion's name",
      AppStrings.renamePetButton: "Rename",
      AppStrings.renamePetDialogTitle: "Rename companion",
      AppStrings.renamePetSuccess: "Name updated!",

      AppStrings.settingsTitle: "Settings",
      AppStrings.settingsSubtitle: "Personalize your experience, Commander.",
      AppStrings.languageSectionTitle: "Language",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Language updated",
      AppStrings.appearanceSectionTitle: "Appearance",
      AppStrings.appearanceLightLabel: "Light",
      AppStrings.appearanceLightDescription: "Bright, clean and friendly",
      AppStrings.appearanceDarkLabel: "Dark",
      AppStrings.appearanceDarkDescription: "Premium, immersive and futuristic",
      AppStrings.appearanceSystemLabel: "System",
      AppStrings.appearanceSystemDescription: "Follows your device settings",
      AppStrings.appearanceUpdated: "Appearance updated",
      AppStrings.notificationsSectionTitle: "Notifications",
      AppStrings.dailyMissionReminders: "Daily mission reminders",
      AppStrings.achievementAlerts: "Achievement alerts",
      AppStrings.privacySectionTitle: "Privacy",
      AppStrings.showOnRankings: "Show up on rankings",
      AppStrings.accountSectionTitle: "Account",
      AppStrings.logoutButton: "Logout",
      AppStrings.logoutConfirmTitle: "Leave Invest Game?",
      AppStrings.logoutConfirmMessage:
          "Are you sure you want to end your session?",
      AppStrings.cancelButton: "Cancel",

      AppStrings.levelUpAchieved: "Level {level} reached!",

      AppStrings.shareProgressLevelLabel: "Level {level}",
      AppStrings.shareProgressXpTotalLabel: "{xp} total XP",
      AppStrings.shareProgressXpToNextLabel:
          "{current}/{total} XP to next level",
      AppStrings.shareProgressLevelUpBadge: "Leveled up!",
      AppStrings.shareProgressTagline:
          "Leveling up toward financial freedom 🚀",
      AppStrings.shareProgressCta:
          "Download Invest Game and start your journey",
      AppStrings.shareProgressButton: "Share",
      AppStrings.shareProgressContinueButton: "Continue",
      AppStrings.shareProgressErrorMessage:
          "Couldn't share right now. Please try again.",
      AppStrings.academyModuleShareTitle: "Module completed!",

      AppStrings.academyLevelLabel: "Investor Level {level}",
      AppStrings.academyXpEarnedLabel: "{xp} XP earned in the Academy",
      AppStrings.academyContinueSectionLabel: "CONTINUE",
      AppStrings.academyXpToCompleteLabel: "+{xp} XP on completion",
      AppStrings.academyStartLessonButton: "Start Lesson",
      AppStrings.academyModulesSectionLabel: "MODULES",
      AppStrings.academyLessonsSectionLabel: "LESSONS",
      AppStrings.academyLessonsProgressLabel: "{completed} / {total} lessons",
      AppStrings.academyLessonCompleteTitle: "Lesson Complete!",
      AppStrings.academyXpPill: "+{xp} XP",
      AppStrings.academyContinueButton: "Continue",
      AppStrings.academyConcludeButton: "Finish",
      AppStrings.academyBackToAcademyButton: "Back to Academy",
      AppStrings.academyModuleStatusCompleted: "MODULE COMPLETED",
      AppStrings.academyModuleStatusInProgress: "IN PROGRESS",
      AppStrings.academyModuleStatusAvailable: "AVAILABLE",
      AppStrings.academyModuleStatusComingSoon: "COMING SOON",
      AppStrings.academyModuleStatusLocked: "LOCKED",
      AppStrings.academyLockedPrerequisiteLabel: "Complete {name} first",
      AppStrings.academySchoolsSectionLabel: "JOURNEY",
      AppStrings.academyDomainsSectionLabel: "SCHOOLS",
      AppStrings.academyCatalogErrorTitle: "Couldn't load the Academy",
      AppStrings.academyCatalogErrorBody:
          "Check your connection and try again.",
      AppStrings.academyMasterySectionLabel: "YOUR MASTERY",
      AppStrings.academyMasteryPercentLabel: "{percent}% complete",
      AppStrings.academyKnowledgeLevelLabel: "Knowledge progress: {tier}",
      AppStrings.academyMicroExerciseLabel: "QUICK EXERCISE",
      AppStrings.academyApplyLabel: "APPLY WHAT YOU LEARNED",
      AppStrings.academyCorrectFeedbackTitle: "That's right!",
      AppStrings.academyIncorrectFeedbackTitle: "Almost! Let's understand:",
      AppStrings.academyCorrectFeedbackTitle2: "Yes! You've got it.",
      AppStrings.academyCorrectFeedbackTitle3: "Nice, you nailed that one!",
      AppStrings.academyIncorrectFeedbackTitle2:
          "Almost. This part trips people up.",
      AppStrings.academyIncorrectFeedbackTitle3:
          "Not this time. Let's take a closer look:",

      AppStrings.academyProgressLabel: "Progress",
      AppStrings.academyRealMasteryLabel: "Mastery",
      AppStrings.masteryTierExploring: "Exploring",
      AppStrings.masteryTierUnderstanding: "Understanding",
      AppStrings.masteryTierApplying: "Applying",
      AppStrings.masteryTierMastering: "Mastering",

      AppStrings.academyRecommendedSectionLabel: "RECOMMENDED FOR YOU",
      AppStrings.academyRecommendationContinueReason:
          "The next step in your journey",
      AppStrings.academyRecommendationReviewReason:
          "You missed a question here — worth a review",
      AppStrings.academyReviewCardTitle: "Today's Review",
      AppStrings.academyReviewCardSubtitle: "{count} lessons · ~{minutes} min",
      AppStrings.academyReviewStartButton: "Start Review",
      AppStrings.academyReviewEmptyState:
          "You're all caught up — nothing to review right now.",

      AppStrings.financialLabSectionLabel: "FINANCIAL LAB",
      AppStrings.financialLabTitle: "Financial Lab",
      AppStrings.financialLabSubtitle:
          "Simulate scenarios and see the concepts in action.",
      AppStrings.labCompoundInterestTitle: "Compound Interest",
      AppStrings.labCompoundInterestSubtitle:
          "See how contributions, time and rate change the outcome.",
      AppStrings.labComingSoon: "Coming soon",
      AppStrings.labInflationTitle: "Inflation",
      AppStrings.labFixedIncomeTitle: "Fixed Income",
      AppStrings.labDiversificationTitle: "Diversification",
      AppStrings.labPortfolioTitle: "Portfolio",
      AppStrings.labInitialAmountLabel: "Initial amount",
      AppStrings.labMonthlyContributionLabel: "Monthly contribution",
      AppStrings.labAnnualReturnLabel: "Annual return",
      AppStrings.labYearsLabel: "Years",
      AppStrings.labFinalValueLabel: "Final value",
      AppStrings.labTotalContributionsLabel: "Total contributed",
      AppStrings.labTotalGrowthLabel: "Total growth",
      AppStrings.labExplanationIncreaseYears:
          "Increasing the time horizon from {from} to {to} years dramatically increased the impact of compound growth.",
      AppStrings.labExplanationDecreaseYears:
          "Reducing the time horizon from {from} to {to} years left less time for compound growth to work.",
      AppStrings.labExplanationIncreaseReturn:
          "Increasing the annual return from {from}% to {to}% sped up how fast your money grows over time.",
      AppStrings.labExplanationDecreaseReturn:
          "Reducing the annual return from {from}% to {to}% slowed down how fast your money grows over time.",
      AppStrings.labExplanationInitial:
          "Adjust the values to see how each variable changes the final result.",
      AppStrings.labYearTooltipLabel: "Year {year}",
      AppStrings.labDataTableDisclosureTitle: "View the numbers as text",
      AppStrings.labExplanationIncreaseInitial:
          "Increasing the initial amount from {from} to {to} gave your money a bigger starting point.",
      AppStrings.labExplanationDecreaseInitial:
          "Lowering the initial amount from {from} to {to} gave compound interest a smaller starting point to work from.",
      AppStrings.labExplanationIncreaseContribution:
          "Increasing the monthly contribution from {from} to {to} speeds up growth since more money goes in every month.",
      AppStrings.labExplanationDecreaseContribution:
          "Lowering the monthly contribution from {from} to {to} makes growth rely more on compounding alone.",
      AppStrings.labCompoundInterestIntro:
          "Adjust the initial amount, monthly contribution, return and years to see how compound interest grows your money.",
      AppStrings.labCompoundInterestInterpretation:
          "Notice how growth (the golden part of the bar) becomes proportionally larger the longer your money stays invested.",
      AppStrings.labCompleteButton: "Complete simulation",
      AppStrings.labCompletedLabel: "Completed",
      AppStrings.labCompoundInterestQuestion:
          "If you keep the same money invested for longer at the same rate, what tends to happen to the interest earned?",
      AppStrings.labCompoundInterestOptionA: "It decreases over time",
      AppStrings.labCompoundInterestOptionB: "It grows proportionally faster",
      AppStrings.labCompoundInterestOptionC: "It stays the same",
      AppStrings.labCompoundInterestAnswerExplanation:
          "With compound interest, you earn interest on the interest you already earned — so growth accelerates the longer your money stays invested.",
      AppStrings.labInflationSubtitle:
          "See how inflation erodes your money's purchasing power.",
      AppStrings.labInflationRateLabel: "Annual inflation",
      AppStrings.labInflationRealValueLabel: "Real purchasing power",
      AppStrings.labInflationNominalValueLabel: "Nominal value",
      AppStrings.labInflationLostPercentLabel: "Purchasing power lost",
      AppStrings.labInflationBasketMultiplierLabel: "Costs today",
      AppStrings.labInflationIntro:
          "Adjust the initial amount, inflation and years to see how the same money buys less and less over time.",
      AppStrings.labInflationInterpretation:
          "With {rate}% annual inflation, the same amount loses {lostPercent}% of its purchasing power over {years} years — the same basket of goods now costs {multiplier} today's price.",
      AppStrings.labInflationInvestingConnection:
          "Exact real return: ({nominal} + 1) ÷ ({inflation} + 1) − 1 = {exact}%. The common \"nominal return − inflation\" shortcut gives {approx}% — close, but not exact.",
      AppStrings.labInflationQuestion:
          "If inflation stays above your investment's return for several years, what happens to your purchasing power?",
      AppStrings.labInflationOptionA: "It increases",
      AppStrings.labInflationOptionB: "It decreases",
      AppStrings.labInflationOptionC: "It stays the same",
      AppStrings.labInflationAnswerExplanation:
          "When inflation outpaces the nominal return, the real return turns negative — your money grows in number, but buys less and less.",
      AppStrings.labFixedIncomeSubtitle:
          "See how rate, term and contributions grow your fixed income.",
      AppStrings.labFixedIncomePrincipalLabel: "Principal invested",
      AppStrings.labFixedIncomeInterestLabel: "Accumulated interest",
      AppStrings.labFixedIncomeNominalRateLabel: "Nominal rate",
      AppStrings.labFixedIncomeEffectiveRateLabel: "Effective annual rate",
      AppStrings.labFixedIncomeGrossDisclaimer:
          "Gross values — taxes and fees vary by product (CDs, bonds, treasuries) and are not included here.",
      AppStrings.labFixedIncomeIntro:
          "Adjust the initial amount, monthly contribution, rate and term to see your fixed income grow — and how the effective rate beats the nominal one thanks to monthly compounding.",
      AppStrings.labFixedIncomeInterpretation:
          "After {years} years invested, interest already makes up {interestShare}% of the final value — the longer the money stays invested, the bigger that share gets.",
      AppStrings.labFixedIncomeQuestion:
          "If the investment term increases at the same rate, what tends to happen to interest's share of the final value?",
      AppStrings.labFixedIncomeOptionA: "It decreases",
      AppStrings.labFixedIncomeOptionB: "It increases",
      AppStrings.labFixedIncomeOptionC: "It disappears",
      AppStrings.labFixedIncomeAnswerExplanation:
          "The longer money stays invested, the more chances interest has to compound on top of previous interest — so its share grows with the term.",
      AppStrings.labInvestmentTypeStocks: "Stocks",
      AppStrings.labInvestmentTypeFixedIncome: "Fixed Income",
      AppStrings.labInvestmentTypeRealEstate: "Real Estate Funds",
      AppStrings.labInvestmentTypeCrypto: "Crypto",
      AppStrings.labInvestmentTypeFunds: "ETFs & Funds",
      AppStrings.labInvestmentTypeOthers: "Others",
      AppStrings.labAllocationTotalLabel: "Total allocated",
      AppStrings.labAllocationHint: "Allocation must add up to 100%.",
      AppStrings.labDiversificationSubtitle:
          "Build a portfolio and see how concentration affects risk.",
      AppStrings.labDiversificationScoreLabel: "Diversification score",
      AppStrings.labDiversificationEffectiveAssetsLabel:
          "Equivalent to how many assets",
      AppStrings.labDiversificationConcentrationLabel: "Largest position",
      AppStrings.labDiversificationIntro:
          "Split 100% across categories and see how concentration changes your simulated portfolio's risk.",
      AppStrings.labDiversificationInterpretation:
          "Your largest position, {category}, is {largestWeight}% of the portfolio — that's like holding only {effectiveAssets} equally-weighted assets.",
      AppStrings.labDiversificationConcentrationShockButton:
          "Largest position falls 30%",
      AppStrings.labDiversificationMarketShockButton: "Everything falls 15%",
      AppStrings.labDiversificationConcentrationShockResult:
          "If {category} fell 30%, your portfolio would lose {impact}% of its total value — the bigger the position, the bigger the hit.",
      AppStrings.labDiversificationMarketShockResult:
          "If every category fell 15% at once, your portfolio would lose 15% — that number is always the same, no matter how you allocated your money.",
      AppStrings.labDiversificationSafetyDisclaimer:
          "Diversifying reduces the risk of concentrating in a single asset, but it does not eliminate market-wide risk — a diversified portfolio is not the same as a risk-free one.",
      AppStrings.labDiversificationQuestion:
          "Diversification protects against…",
      AppStrings.labDiversificationOptionA:
          "Concentration risk in a single asset",
      AppStrings.labDiversificationOptionB: "Any market downturn",
      AppStrings.labDiversificationOptionC: "Every possible loss",
      AppStrings.labDiversificationAnswerExplanation:
          "Diversification reduces how much a single position can hurt you, but when the whole market falls, a diversified portfolio still feels the impact.",
      AppStrings.labPortfolioSubtitle:
          "Build a hypothetical portfolio and test market scenarios.",
      AppStrings.labPortfolioTotalAmountLabel: "Simulated total value",
      AppStrings.labPortfolioNewValueLabel: "Value after the scenario",
      AppStrings.labPortfolioDeltaLabel: "Change",
      AppStrings.labPortfolioIntro:
          "Build a hypothetical portfolio, pick a scenario, and see how its composition changes the portfolio's response — without touching your real portfolio.",
      AppStrings.labPortfolioSandboxDisclaimer:
          "This is a hypothetical lab portfolio — nothing here affects your real Portfolio.",
      AppStrings.labPortfolioForecastDisclaimer:
          "These scenarios are educational simulations and do not predict future returns.",
      AppStrings.labPortfolioScenarioEquitiesDown15: "Stocks fall 15%",
      AppStrings.labPortfolioScenarioLargestPositionDown20:
          "Largest position falls 20%",
      AppStrings.labPortfolioScenarioBroadMarketDown10: "Everything falls 10%",
      AppStrings.labPortfolioScenarioFixedIncomeUp5: "Fixed income rises 5%",
      AppStrings.labPortfolioScenarioResult:
          "Under this scenario, your simulated portfolio would change {deltaPercent}%, from {before} to {after} — the portfolio reacts differently than any single asset alone.",
      AppStrings.labPortfolioQuestion:
          "Why does a scenario's impact on the whole portfolio usually differ from its impact on a single asset?",
      AppStrings.labPortfolioOptionA:
          "Because the portfolio combines assets with different weights",
      AppStrings.labPortfolioOptionB:
          "Because every asset always moves together",
      AppStrings.labPortfolioOptionC: "Because the portfolio ignores scenarios",
      AppStrings.labPortfolioAnswerExplanation:
          "The total impact is the weighted sum of each category's impact — so the portfolio as a whole reacts in a way no single asset reflects on its own.",

      AppStrings.appBarPlayerNamedGreeting: "{petName} · Level {level}",
      AppStrings.appBarPlayerGenericGreeting: "Level {level} · Explorer",
      AppStrings.profileTooltip: "Profile",
      AppStrings.notificationsTooltip: "Notifications",
      AppStrings.logoutTooltip: "Logout",
      AppStrings.navHome: "Home",
      AppStrings.navWallet: "Wallet",
      AppStrings.navPassiveIncome: "Income",
      AppStrings.navAcademy: "Academy",
      AppStrings.navMentor: "Mentor",
      AppStrings.homeContinueLearningEyebrow: "Today's mission",
      AppStrings.homeContinueLearningCta: "Continue Learning",
      AppStrings.homeAllLessonsCompleteTitle:
          "You've completed everything here!",
      AppStrings.homeAllLessonsCompleteBody:
          "New modules are coming soon. Explore the Academy to review what you've learned.",
      AppStrings.homeExploreAcademyCta: "View Academy",
      AppStrings.homeLevelProgressLabel: "XP to next level",
      AppStrings.homeNextEvolutionLabel: "XP to next evolution",
      AppStrings.homeMaxEvolutionLabel: "Maximum evolution reached",
      AppStrings.homeKnowledgeMapLabel: "YOUR KNOWLEDGE MAP",
      AppStrings.homeViewFullAcademyCta: "View full path",
      AppStrings.homePortfolioBridgeLabel: "YOUR PORTFOLIO",
      AppStrings.homePortfolioBridgeApplyMessage:
          "You've completed {count} lessons — see how to apply that knowledge to your real portfolio.",
      AppStrings.homeViewPortfolioCta: "View Portfolio",
      AppStrings.homeAnswerInvestorProfileLink:
          "Haven't answered your risk profile yet? Answer now",
      AppStrings.homeMissionAlmostDoneEyebrow: "Almost there",
      AppStrings.homeMissionAlmostDoneBody:
          "1 more lesson finishes this mission and earns +{xp} XP.",
      AppStrings.levelTierBeginner: "Beginner",
      AppStrings.levelTierLearner: "Learner",
      AppStrings.levelTierExplorer: "Explorer",
      AppStrings.levelTierInvestor: "Investor",
      AppStrings.levelTierAnalyst: "Analyst",
      AppStrings.levelTierStrategist: "Strategist",
      AppStrings.levelTierSpecialist: "Specialist",

      // Knowledge Progress tiers (curriculum completion, not XP)
      AppStrings.knowledgeLevelAbsoluteBeginner: "Absolute Beginner",
      AppStrings.knowledgeLevelFinancialApprentice: "Financial Apprentice",
      AppStrings.knowledgeLevelFinancialOrganizer: "Financial Organizer",
      AppStrings.knowledgeLevelFinancialProtector: "Financial Protector",
      AppStrings.knowledgeLevelBeginnerInvestor: "Beginner Investor",
      AppStrings.knowledgeLevelInvestor: "Investor",
      AppStrings.knowledgeLevelAnalyst: "Analyst",
      AppStrings.knowledgeLevelWealthBuilder: "Wealth Builder",
      AppStrings.knowledgeLevelFinancialStrategist: "Financial Strategist",
      AppStrings.knowledgeLevelFinancialMaster: "Financial Master",

      AppStrings.companionHeaderTooltip: "Open your companion",
      AppStrings.companionDismissTooltip: "Dismiss",
      AppStrings.companionInteractionTitle: "How can I help?",
      AppStrings.companionInteractionSubtitle: "Choose where to go",
      AppStrings.companionInteractionLearn: "Learn",
      AppStrings.companionInteractionPortfolio: "Portfolio",
      AppStrings.companionInteractionProgress: "Progress",
      AppStrings.companionActionContinue: "Continue",
      AppStrings.companionActionViewPortfolio: "View Portfolio",
      AppStrings.companionActionViewProgress: "View Progress",
      AppStrings.companionHomeXpToNextLevel: "Only {xp} XP to your next level!",
      AppStrings.companionAcademyContinueLesson:
          "You were making progress on \"{lessonTitle}\". Continue where you left off?",
      AppStrings.companionAcademyReviewDue:
          "You have {count} concepts to review. Let's reinforce what you've learned?",
      AppStrings.companionPortfolioDiversified:
          "Your portfolio is spread across {count} different assets.",
      AppStrings.companionMentorNudge:
          "Have a question about investing? Ask me anything.",
      AppStrings.companionProfileSummary: "You're at level {level} — {stage}.",
      AppStrings.companionEventLessonCompleted:
          "Great job! You completed the lesson.",
      AppStrings.companionEventXpGained: "+{xp} XP! Keep it up.",
      AppStrings.companionEventLevelUp:
          "Level {level} reached! I'm proud of you.",
      AppStrings.companionEventAchievementUnlocked:
          "Achievement unlocked: {title}!",
      AppStrings.companionEventEvolved: "I evolved! I'm now {stage}.",
      AppStrings.companionEventDifficultyDetected:
          "I noticed a few misses in {school}. Want to review it together?",
      AppStrings.companionEventSchoolMastered:
          "You finished everything available in {school}! Well done!",
      AppStrings.companionEventFirstInvestment:
          "That was your first investment! Want to understand what you just added to your portfolio?",
      AppStrings.companionEventHighConcentration:
          "I noticed {ticker} makes up {percent}% of your portfolio. Want to understand why diversifying can lower your risk?",
      AppStrings.companionPortfolioActivationNudge:
          "Every investor's journey starts with a first step. I'm here whenever you want to take yours.",
      AppStrings.companionInvestorStatusYes:
          "Great! Let's start by registering your first investment.",
      AppStrings.companionInvestorStatusNo:
          "No problem! You don't need investments to start your journey.",
      AppStrings.companionActionUnderstand: "Understand",
      AppStrings.companionHomeMotivation1:
          "Every small step gets you more prepared for the future. Keep it up!",
      AppStrings.companionHomeMotivation2:
          "Investing is a marathon, not a sprint. Your consistency is already an achievement.",
      AppStrings.companionHomeMotivation3:
          "You're building a habit that'll pay off. Proud to be on this journey with you.",
      AppStrings.companionHomeMotivation4:
          "Learning about money is one of the best investments you can make. Ready to keep going?",
      AppStrings.companionHomeMotivation5:
          "Every day you come back here is a day closer to your goals.",
      AppStrings.companionHomeReturnGreeting1:
          "Good to see you again! Ready to pick up where you left off?",
      AppStrings.companionHomeReturnGreeting2:
          "Glad you're back! Your journey is still waiting for you.",
      AppStrings.companionHomeMissionAlmostDone:
          "You're one lesson away from finishing '{missionTitle}'!",
      AppStrings.companionEventMissionCompleted:
          "Mission complete: {title}! Another step toward a more confident investor.",
      AppStrings.companionEventLabSimulatorCompleted:
          "You finished the {simulator} simulator! That's understanding investing in practice.",

      AppStrings.forgotPasswordTitle: "Recover password",
      AppStrings.forgotPasswordSubtitle:
          "Enter your email and we'll send you a link to reset your password.",
      AppStrings.forgotPasswordEmailHint: "Your email",
      AppStrings.forgotPasswordSendButton: "Send link",
      AppStrings.forgotPasswordConfirmationMessage:
          "If an account exists for that email, you'll receive instructions shortly.",
      AppStrings.forgotPasswordHaveCodeLink: "I already have a reset code",
      AppStrings.resetPasswordTitle: "Reset password",
      AppStrings.resetPasswordSubtitle:
          "Paste the code we emailed you and choose a new password.",
      AppStrings.resetPasswordTokenHint: "Reset code",
      AppStrings.resetPasswordNewPasswordHint: "New password",
      AppStrings.resetPasswordSubmitButton: "Reset password",
      AppStrings.resetPasswordSuccessMessage:
          "Password reset successfully! Log in with your new password.",
      AppStrings.resetPasswordMismatchError: "Passwords don't match.",
      AppStrings.resetPasswordFieldsRequiredError: "Please fill in all fields.",

      AppStrings.wealthLegendPatrimony: "Net worth",
      AppStrings.wealthLegendInvested: "Invested",
      AppStrings.wealthLegendAppliedValue: "Amount invested",
      AppStrings.wealthLegendCapitalGain: "Capital gain",
      AppStrings.proventosLegendReceived: "Received",
      AppStrings.proventosLegendExpected: "Expected",
      AppStrings.noAssetsRegisteredYet: "No assets registered yet.",
      AppStrings.retryButtonLabel: "Try again",
      AppStrings.errorNoConnectionMessage:
          "Couldn't connect. Check your internet connection and try again.",
      AppStrings.errorUnexpectedMessage:
          "Something unexpected happened. Please try again.",
      AppStrings.mentorNewChatTooltip: "New chat",
      AppStrings.mentorHistoryTooltip: "History",
      AppStrings.mentorConversationHistoryTitle: "Conversations",
      AppStrings.mentorNoConversationsTitle: "No conversations yet",
      AppStrings.mentorNoConversationsSubtitle:
          "Your conversations with the mentor will show up here.",
      AppStrings.mentorConversationsLoadError:
          "We couldn't load your conversations.",
      AppStrings.mentorRenameConversationTitle: "Rename conversation",
      AppStrings.mentorRenameConversationHint: "Conversation title",
      AppStrings.mentorRenameConversationSave: "Save",
      AppStrings.mentorRenameConversationFailed:
          "We couldn't rename the conversation. Please try again.",
      AppStrings.mentorDeleteConversationTitle: "Delete conversation?",
      AppStrings.mentorDeleteConversationConfirm:
          "This conversation and all its messages will be permanently deleted.",
      AppStrings.mentorDeleteConversationButton: "Delete",
      AppStrings.mentorDeleteConversationFailed:
          "We couldn't delete the conversation. Please try again.",
      AppStrings.initialPortfolioTitle: "Starting Portfolio",
      AppStrings.portfolioCardTitle: "Portfolio",
      AppStrings.profileTitle: "Profile",
      AppStrings.profileCommanderTitle: "Commander Profile",
      AppStrings.profileAchievementsLabel: "Achievements",
      AppStrings.profileAchievementsComingSoonBody:
          "Your achievements and milestones will appear here as you progress.",
      AppStrings.profileSettingsHint:
          "Manage language and account in Settings.",
      AppStrings.investorProfileScreenTitle: "Risk Profile",
      AppStrings.investorProfileScreenSubtitle:
          "Different from your financial goal — this is about how you relate to risk.",
      AppStrings.investorProfileClearAnswersButton: "Clear answers",
      AppStrings.investorProfileClearAnswers: "Answers cleared.",
      AppStrings.petTeacherAskMentor: "Ask the mentor:",
      AppStrings.petTeacherOwnedGreeting:
          "Let's understand {assetName} better!",
      AppStrings.petTeacherNotOwnedGreeting:
          "Want to know more about {assetName}?",
    },
    'es': {
      AppStrings.welcomeBack: "Bienvenido de nuevo",
      AppStrings.loginToContinue: "Inicia sesión para continuar",
      AppStrings.emailOrUserHint: "Correo o Usuario",
      AppStrings.passwordHint: "Contraseña",
      AppStrings.forgotPassword: "¿Olvidaste tu contraseña?",
      AppStrings.noAccountSignUp: "¿No tienes cuenta? Regístrate",
      AppStrings.loginButton: "Entrar",
      AppStrings.continueWithGoogle: "Continuar con Google",
      AppStrings.orDivider: "o",
      AppStrings.createAccount: "Crear Cuenta",
      AppStrings.fillDetails: "Completa tus datos",
      AppStrings.nameHint: "Nombre Completo",
      AppStrings.confirmPasswordHint: "Confirmar Contraseña",
      AppStrings.signupButton: "Registrarse",
      AppStrings.alreadyHaveAccount: "¿Ya tienes cuenta? Entrar",

      AppStrings.pleaseAnswerAllQuestions: "Responde todas las preguntas",
      AppStrings.onboardingFailed: "Error al enviar las respuestas",
      AppStrings.noQuestionsAvailable: "No hay preguntas disponibles.",
      AppStrings.failedToLoadQuestions: "Error al cargar las preguntas",

      AppStrings.petProfileTitle: "Perfil de la Mascota",
      AppStrings.failedToSavePet: "Error al guardar la mascota",

      AppStrings.meetPetTitle: "Conoce a tu Compañero",
      AppStrings.meetPetGreeting: "¡Hola!",
      AppStrings.meetPetIntro:
          "Soy tu compañero financiero. Te ayudaré a aprender sobre inversiones, mantener la disciplina y celebrar cada logro en tu camino.",
      AppStrings.meetPetNeedName: "Pero antes... ¡necesito un nombre!",
      AppStrings.meetPetSpeciesPrompt: "Elige la especie de tu compañero",
      AppStrings.meetPetContinue: "¡Vamos a empezar!",
      AppStrings.meetPetPreviewTitle: "Lo que haremos juntos",
      AppStrings.meetPetPreviewCelebrate: "Celebrar cada logro de tu viaje",
      AppStrings.meetPetPreviewLearn: "Aprender sobre inversiones a tu ritmo",
      AppStrings.meetPetPreviewRemember:
          "Recordar los momentos importantes de nuestro viaje",

      AppStrings.namePetTitle: "Nombra a tu Mascota",
      AppStrings.namePetPrompt: "¿Cómo te gustaría llamar a tu compañero?",
      AppStrings.namePetHint: "Nombre del compañero",
      AppStrings.namePetContinue: "Continuar",
      AppStrings.namePetReaction:
          "¡Me encanta mi nuevo nombre! ¡Comencemos tu viaje!",
      AppStrings.namePetRequiredError: "Elige un nombre para continuar",

      AppStrings.financialGoalTitle: "¿Cuál será tu primera misión?",
      AppStrings.financialGoalSubtitle:
          "Elige lo que quieres lograr. Puedes cambiarlo después.",
      AppStrings.financialGoalContinue: "Continuar",

      AppStrings.onboardingSkip: "Omitir",
      AppStrings.onboardingNext: "Siguiente",

      AppStrings.welcomeHeadline: "Tu viaje financiero comienza aquí.",
      AppStrings.welcomeSubheadline: "Aprende. Invierte. Evoluciona.",
      AppStrings.welcomeBody:
          "Convierte el conocimiento financiero en progreso real.",
      AppStrings.welcomeCta: "Comenzar",

      AppStrings.academyIntroTitle: "Aprende a tu ritmo.",
      AppStrings.academyIntroSubtitle: "Conocimiento antes de invertir.",
      AppStrings.academyIntroBody:
          "Lecciones cortas, desafíos y quizzes para que realmente entiendas de inversiones.",
      AppStrings.academyIntroXpBadge: "+{xp} XP por lección completada",

      AppStrings.gamificationIntroTitle: "Aprende. Juega. Evoluciona.",
      AppStrings.gamificationIntroSubtitle:
          "Convierte el conocimiento en progreso.",
      AppStrings.onboardingLevelBadge: "Nivel {level}",

      AppStrings.missionCompleteLabel: "Misión Completada",
      AppStrings.missionCompoundInterestTitle:
          "Aprende sobre el interés compuesto",

      AppStrings.timeHorizonTitle: "¿Cuándo quieres lograrlo?",
      AppStrings.timeHorizonSubtitle:
          "Esto marca el ritmo de tu viaje — puedes cambiarlo después.",

      AppStrings.journeyReadyTitle: "Tu viaje está listo.",
      AppStrings.journeyReadySubtitle:
          "Ahora es momento de empezar a evolucionar.",
      AppStrings.journeyReadyGoalLabel: "Tu objetivo",
      AppStrings.journeyReadyPathLabel: "Tu camino",
      AppStrings.journeyReadyPathValue: "Aprender a Invertir",
      AppStrings.journeyReadyCompanionLabel: "Tu compañero",
      AppStrings.journeyReadyProgressLabel: "Tu progreso",
      AppStrings.journeyReadyFirstMissionLabel: "Tu primera misión",
      AppStrings.journeyReadyCta: "Iniciar Mi Viaje",

      AppStrings.portfolioChoiceTitle: "Empieza por el conocimiento.",
      AppStrings.portfolioChoiceBody:
          "No necesitas tener inversiones para comenzar tu camino. Aprende a tu ritmo e invierte cuando te sientas preparado.",
      AppStrings.portfolioChoiceFootnote:
          "Sin prisa — {petName} estará aquí en cada etapa.",
      AppStrings.portfolioGuidanceLearnTitle: "Aprende antes de invertir",
      AppStrings.portfolioGuidanceLearnBody:
          "Explora las lecciones y comprende cómo tomar decisiones más conscientes antes de invertir tu dinero.",
      AppStrings.portfolioGuidancePortfolioTitle:
          "Tu cartera entra cuando tenga sentido",
      AppStrings.portfolioGuidancePortfolioBody:
          "Cuando comiences a invertir, registra tus activos aquí para seguir tu evolución.",
      AppStrings.portfolioGuidanceMentorTitle: "Cuenta con tu mentor",
      AppStrings.portfolioGuidanceMentorBody:
          "Con tu cartera registrada, el mentor podrá analizar tu progreso y ayudarte a aprender.",
      AppStrings.portfolioGuidanceContinueButton: "Empezar a aprender",
      AppStrings.importPortfolioButton: "Importar Portafolio",
      AppStrings.addManuallyButton: "Agregar Manualmente",
      AppStrings.skipForNowButton: "Omitir por Ahora",
      AppStrings.importComingSoonBody:
          "La importación automática (B3, corredoras, CSV) todavía se está construyendo. Por ahora, puedes agregar tus activos manualmente u omitir este paso.",
      AppStrings.portfolioActivationIntroTitle: "Tu cartera empieza aquí.",
      AppStrings.portfolioActivationIntroBody:
          "Sigue tus inversiones, entiende tu evolución y convierte el conocimiento en decisiones más conscientes.",
      AppStrings.portfolioActivationStartButton: "Vamos a empezar",
      AppStrings.portfolioActivationStatusQuestion: "¿Ya inviertes?",
      AppStrings.portfolioActivationStatusYes: "Sí, ya invierto",
      AppStrings.portfolioActivationStatusNo: "Todavía no",
      AppStrings.portfolioActivationConnectTitle:
          "Vamos a agregar tu primera inversión.",
      AppStrings.portfolioActivationConnectBody:
          "Registra tus activos para empezar a seguir tu cartera.",
      AppStrings.portfolioActivationAddFirstAssetButton:
          "Agregar mi primer activo",
      AppStrings.portfolioActivationLearnTitle:
          "Está bien. Puedes empezar aprendiendo.",
      AppStrings.portfolioActivationLearnBody:
          "No necesitas tener inversiones para empezar tu camino como inversor.",
      AppStrings.portfolioActivationStartAcademyButton:
          "Empezar por la Academia",
      AppStrings.portfolioActivationExploreJourneyButton: "Explorar mi camino",
      AppStrings.portfolioActivationReturningNudge:
          "Todavía no agregaste tu primera inversión. Cuando estés listo, podemos empezar.",
      AppStrings.portfolioActivationReturningAddAsset: "Agregar activo",
      AppStrings.portfolioActivationReturningGoAcademy: "Ir a la Academia",

      AppStrings.portfolioNotConnectedTitle: "Portafolio aún no conectado",
      AppStrings.portfolioNotConnectedBody:
          "Conecta tus inversiones cuando estés listo — no hay prisa.",
      AppStrings.connectInvestmentsButton: "Conectar Inversiones",
      AppStrings.suggestedActionsTitle: "Qué hacer ahora",
      AppStrings.suggestedActionCompleteLesson: "Completar tu primera lección",
      AppStrings.suggestedActionTodayMission: "Completar la misión de hoy",
      AppStrings.suggestedActionLearnDividends: "Aprender sobre dividendos",
      AppStrings.suggestedActionFirstQuiz: "Hacer tu primer quiz",
      AppStrings.suggestedActionInvestorProfile:
          "Completar tu perfil de inversionista",
      AppStrings.comingSoonSnack: "¡Próximamente!",

      AppStrings.portfolioReminderMessage:
          "Noté que todavía no hemos conectado tus inversiones. Cuando estés listo, puedo analizar tu portafolio y crear misiones personalizadas. No hay prisa.",
      AppStrings.portfolioReminderCta: "Conectar ahora",
      AppStrings.portfolioReminderDismiss: "Ahora no",

      AppStrings.companionSectionTitle: "Compañero",
      AppStrings.renamePetLabel: "Nombre del compañero",
      AppStrings.renamePetButton: "Renombrar",
      AppStrings.renamePetDialogTitle: "Renombrar compañero",
      AppStrings.renamePetSuccess: "¡Nombre actualizado!",

      AppStrings.settingsTitle: "Configuración",
      AppStrings.settingsSubtitle: "Personaliza tu experiencia, Comandante.",
      AppStrings.languageSectionTitle: "Idioma",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Idioma actualizado",
      AppStrings.appearanceSectionTitle: "Apariencia",
      AppStrings.appearanceLightLabel: "Claro",
      AppStrings.appearanceLightDescription: "Brillante, limpio y acogedor",
      AppStrings.appearanceDarkLabel: "Oscuro",
      AppStrings.appearanceDarkDescription: "Premium, inmersivo y futurista",
      AppStrings.appearanceSystemLabel: "Sistema",
      AppStrings.appearanceSystemDescription:
          "Sigue la configuración de tu dispositivo",
      AppStrings.appearanceUpdated: "Apariencia actualizada",
      AppStrings.notificationsSectionTitle: "Notificaciones",
      AppStrings.dailyMissionReminders: "Recordatorios de misiones diarias",
      AppStrings.achievementAlerts: "Alertas de logros",
      AppStrings.privacySectionTitle: "Privacidad",
      AppStrings.showOnRankings: "Aparecer en los rankings",
      AppStrings.accountSectionTitle: "Cuenta",
      AppStrings.logoutButton: "Salir",
      AppStrings.logoutConfirmTitle: "¿Salir de Invest Game?",
      AppStrings.logoutConfirmMessage: "¿Seguro que deseas cerrar tu sesión?",
      AppStrings.cancelButton: "Cancelar",

      AppStrings.levelUpAchieved: "¡Nivel {level} alcanzado!",

      AppStrings.shareProgressLevelLabel: "Nivel {level}",
      AppStrings.shareProgressXpTotalLabel: "{xp} XP totales",
      AppStrings.shareProgressXpToNextLabel:
          "{current}/{total} XP para el próximo nivel",
      AppStrings.shareProgressLevelUpBadge: "¡Subió de nivel!",
      AppStrings.shareProgressTagline:
          "Evolucionando hacia la libertad financiera 🚀",
      AppStrings.shareProgressCta: "Descarga Invest Game y comienza tu viaje",
      AppStrings.shareProgressButton: "Compartir",
      AppStrings.shareProgressContinueButton: "Continuar",
      AppStrings.shareProgressErrorMessage:
          "No se pudo compartir ahora. Inténtalo de nuevo.",
      AppStrings.academyModuleShareTitle: "¡Módulo completado!",

      AppStrings.academyLevelLabel: "Inversor Nivel {level}",
      AppStrings.academyXpEarnedLabel: "{xp} XP conseguidos en la Academia",
      AppStrings.academyContinueSectionLabel: "CONTINUAR",
      AppStrings.academyXpToCompleteLabel: "+{xp} XP al completar",
      AppStrings.academyStartLessonButton: "Comenzar Lección",
      AppStrings.academyModulesSectionLabel: "MÓDULOS",
      AppStrings.academyLessonsSectionLabel: "LECCIONES",
      AppStrings.academyLessonsProgressLabel: "{completed} / {total} lecciones",
      AppStrings.academyLessonCompleteTitle: "¡Lección Completada!",
      AppStrings.academyXpPill: "+{xp} XP",
      AppStrings.academyContinueButton: "Continuar",
      AppStrings.academyConcludeButton: "Concluir",
      AppStrings.academyBackToAcademyButton: "Volver a la Academia",
      AppStrings.academyModuleStatusCompleted: "MÓDULO COMPLETADO",
      AppStrings.academyModuleStatusInProgress: "EN CURSO",
      AppStrings.academyModuleStatusAvailable: "DISPONIBLE",
      AppStrings.academyModuleStatusComingSoon: "PRÓXIMAMENTE",
      AppStrings.academyModuleStatusLocked: "BLOQUEADO",
      AppStrings.academyLockedPrerequisiteLabel: "Completa {name} primero",
      AppStrings.academySchoolsSectionLabel: "RECORRIDO",
      AppStrings.academyDomainsSectionLabel: "ESCUELAS",
      AppStrings.academyCatalogErrorTitle: "No se pudo cargar la Academia",
      AppStrings.academyCatalogErrorBody:
          "Verifica tu conexión e inténtalo de nuevo.",
      AppStrings.academyMasterySectionLabel: "TU MAESTRÍA",
      AppStrings.academyMasteryPercentLabel: "{percent}% completado",
      AppStrings.academyKnowledgeLevelLabel: "Progreso de conocimiento: {tier}",
      AppStrings.academyMicroExerciseLabel: "EJERCICIO RÁPIDO",
      AppStrings.academyApplyLabel: "APLICA LO QUE APRENDISTE",
      AppStrings.academyCorrectFeedbackTitle: "¡Exacto!",
      AppStrings.academyIncorrectFeedbackTitle: "¡Casi! Vamos a entender:",
      AppStrings.academyCorrectFeedbackTitle2: "¡Eso! Lo entendiste.",
      AppStrings.academyCorrectFeedbackTitle3: "¡Bien, acertaste esa!",
      AppStrings.academyIncorrectFeedbackTitle2:
          "Casi. Esta parte suele confundir.",
      AppStrings.academyIncorrectFeedbackTitle3:
          "Esta vez no. Vamos verlo con calma:",

      AppStrings.academyProgressLabel: "Progreso",
      AppStrings.academyRealMasteryLabel: "Maestría",
      AppStrings.masteryTierExploring: "Explorando",
      AppStrings.masteryTierUnderstanding: "Entendiendo",
      AppStrings.masteryTierApplying: "Aplicando",
      AppStrings.masteryTierMastering: "Dominando",

      AppStrings.academyRecommendedSectionLabel: "RECOMENDADO PARA TI",
      AppStrings.academyRecommendationContinueReason:
          "El siguiente paso de tu recorrido",
      AppStrings.academyRecommendationReviewReason:
          "Fallaste una pregunta aquí — vale la pena repasar",
      AppStrings.academyReviewCardTitle: "Repaso de hoy",
      AppStrings.academyReviewCardSubtitle:
          "{count} lecciones · ~{minutes} min",
      AppStrings.academyReviewStartButton: "Comenzar repaso",
      AppStrings.academyReviewEmptyState:
          "Todo al día — nada que repasar por ahora.",

      AppStrings.financialLabSectionLabel: "LABORATORIO FINANCIERO",
      AppStrings.financialLabTitle: "Laboratorio Financiero",
      AppStrings.financialLabSubtitle:
          "Simula escenarios y mira los conceptos en acción.",
      AppStrings.labCompoundInterestTitle: "Interés Compuesto",
      AppStrings.labCompoundInterestSubtitle:
          "Mira cómo el aporte, el plazo y la tasa cambian el resultado.",
      AppStrings.labComingSoon: "Próximamente",
      AppStrings.labInflationTitle: "Inflación",
      AppStrings.labFixedIncomeTitle: "Renta Fija",
      AppStrings.labDiversificationTitle: "Diversificación",
      AppStrings.labPortfolioTitle: "Cartera",
      AppStrings.labInitialAmountLabel: "Monto inicial",
      AppStrings.labMonthlyContributionLabel: "Aporte mensual",
      AppStrings.labAnnualReturnLabel: "Retorno anual",
      AppStrings.labYearsLabel: "Años",
      AppStrings.labFinalValueLabel: "Valor final",
      AppStrings.labTotalContributionsLabel: "Total invertido",
      AppStrings.labTotalGrowthLabel: "Total en rendimientos",
      AppStrings.labExplanationIncreaseYears:
          "Aumentar el plazo de {from} a {to} años amplió mucho el efecto del interés compuesto sobre el resultado.",
      AppStrings.labExplanationDecreaseYears:
          "Reducir el plazo de {from} a {to} años dejó menos tiempo para que actuara el interés compuesto.",
      AppStrings.labExplanationIncreaseReturn:
          "Aumentar el retorno anual de {from}% a {to}% aceleró el crecimiento de tu dinero con el tiempo.",
      AppStrings.labExplanationDecreaseReturn:
          "Reducir el retorno anual de {from}% a {to}% desaceleró el crecimiento de tu dinero con el tiempo.",
      AppStrings.labExplanationInitial:
          "Ajusta los valores para ver cómo cada variable cambia el resultado final.",
      AppStrings.labYearTooltipLabel: "Año {year}",
      AppStrings.labDataTableDisclosureTitle: "Ver los números en texto",
      AppStrings.labExplanationIncreaseInitial:
          "Aumentar el valor inicial de {from} a {to} le dio a tu dinero un punto de partida mayor.",
      AppStrings.labExplanationDecreaseInitial:
          "Reducir el valor inicial de {from} a {to} le dio al interés compuesto un punto de partida menor.",
      AppStrings.labExplanationIncreaseContribution:
          "Aumentar el aporte mensual de {from} a {to} acelera el crecimiento porque entra más dinero cada mes.",
      AppStrings.labExplanationDecreaseContribution:
          "Reducir el aporte mensual de {from} a {to} hace que el crecimiento dependa más del interés compuesto solo.",
      AppStrings.labCompoundInterestIntro:
          "Ajusta el valor inicial, el aporte mensual, el retorno y los años para ver cómo el interés compuesto hace crecer tu dinero.",
      AppStrings.labCompoundInterestInterpretation:
          "Observa cómo el crecimiento (la parte dorada de la barra) se vuelve proporcionalmente mayor cuanto más tiempo permanece invertido tu dinero.",
      AppStrings.labCompleteButton: "Concluir simulación",
      AppStrings.labCompletedLabel: "Concluido",
      AppStrings.labCompoundInterestQuestion:
          "Si dejas el mismo dinero invertido por más tiempo, manteniendo la misma tasa, ¿qué tiende a pasar con los intereses ganados?",
      AppStrings.labCompoundInterestOptionA: "Disminuyen con el tiempo",
      AppStrings.labCompoundInterestOptionB:
          "Crecen proporcionalmente más rápido",
      AppStrings.labCompoundInterestOptionC: "Se mantienen siempre iguales",
      AppStrings.labCompoundInterestAnswerExplanation:
          "En el interés compuesto, ganas intereses sobre los intereses ya ganados antes — por eso el crecimiento se acelera cuanto más tiempo permanece invertido el dinero.",
      AppStrings.labInflationSubtitle:
          "Mira cómo la inflación erosiona el poder de compra de tu dinero.",
      AppStrings.labInflationRateLabel: "Inflación anual",
      AppStrings.labInflationRealValueLabel: "Poder de compra real",
      AppStrings.labInflationNominalValueLabel: "Valor nominal",
      AppStrings.labInflationLostPercentLabel: "Poder de compra perdido",
      AppStrings.labInflationBasketMultiplierLabel: "Cuesta hoy",
      AppStrings.labInflationIntro:
          "Ajusta el valor inicial, la inflación y los años para ver cómo el mismo dinero compra cada vez menos con el tiempo.",
      AppStrings.labInflationInterpretation:
          "Con {rate}% de inflación anual, el mismo valor pierde {lostPercent}% de su poder de compra en {years} años — la misma canasta de productos ahora cuesta {multiplier} el precio de hoy.",
      AppStrings.labInflationInvestingConnection:
          "Retorno real exacto: ({nominal} + 1) ÷ ({inflation} + 1) − 1 = {exact}%. La aproximación común \"retorno nominal − inflación\" da {approx}% — cercana, pero no exacta.",
      AppStrings.labInflationQuestion:
          "Si la inflación se mantiene por encima del retorno de tu inversión durante varios años, ¿qué pasa con tu poder de compra?",
      AppStrings.labInflationOptionA: "Aumenta",
      AppStrings.labInflationOptionB: "Disminuye",
      AppStrings.labInflationOptionC: "Se mantiene igual",
      AppStrings.labInflationAnswerExplanation:
          "Cuando la inflación supera el retorno nominal, el retorno real se vuelve negativo — tu dinero crece en número, pero compra cada vez menos.",
      AppStrings.labFixedIncomeSubtitle:
          "Mira cómo la tasa, el plazo y los aportes hacen crecer tu renta fija.",
      AppStrings.labFixedIncomePrincipalLabel: "Principal invertido",
      AppStrings.labFixedIncomeInterestLabel: "Intereses acumulados",
      AppStrings.labFixedIncomeNominalRateLabel: "Tasa nominal",
      AppStrings.labFixedIncomeEffectiveRateLabel: "Tasa efectiva anual",
      AppStrings.labFixedIncomeGrossDisclaimer:
          "Valores brutos — los impuestos y comisiones varían según el producto (CDB, LCI, LCA, Tesoro) y no están incluidos aquí.",
      AppStrings.labFixedIncomeIntro:
          "Ajusta el valor inicial, el aporte mensual, la tasa y el plazo para ver cómo crece tu renta fija — y cómo la tasa efectiva supera a la nominal gracias a la capitalización mensual.",
      AppStrings.labFixedIncomeInterpretation:
          "Con {years} años invertidos, los intereses ya representan el {interestShare}% del valor final — cuanto más tiempo permanece invertido el dinero, mayor es esa parte.",
      AppStrings.labFixedIncomeQuestion:
          "Si el plazo de la inversión aumenta manteniendo la misma tasa, ¿qué tiende a pasar con la parte de intereses en el valor final?",
      AppStrings.labFixedIncomeOptionA: "Disminuye",
      AppStrings.labFixedIncomeOptionB: "Aumenta",
      AppStrings.labFixedIncomeOptionC: "Desaparece",
      AppStrings.labFixedIncomeAnswerExplanation:
          "Cuanto más tiempo permanece invertido el dinero, más oportunidades tienen los intereses de componerse sobre intereses anteriores — por eso esa parte crece con el plazo.",
      AppStrings.labInvestmentTypeStocks: "Acciones",
      AppStrings.labInvestmentTypeFixedIncome: "Renta Fija",
      AppStrings.labInvestmentTypeRealEstate: "Fondos Inmobiliarios",
      AppStrings.labInvestmentTypeCrypto: "Cripto",
      AppStrings.labInvestmentTypeFunds: "ETFs y Fondos",
      AppStrings.labInvestmentTypeOthers: "Otros",
      AppStrings.labAllocationTotalLabel: "Total asignado",
      AppStrings.labAllocationHint: "La asignación debe sumar 100%.",
      AppStrings.labDiversificationSubtitle:
          "Arma una cartera y mira cómo la concentración afecta el riesgo.",
      AppStrings.labDiversificationScoreLabel: "Índice de diversificación",
      AppStrings.labDiversificationEffectiveAssetsLabel:
          "Equivale a cuántos activos",
      AppStrings.labDiversificationConcentrationLabel: "Mayor posición",
      AppStrings.labDiversificationIntro:
          "Distribuye 100% entre las categorías y mira cómo la concentración cambia el riesgo de tu cartera simulada.",
      AppStrings.labDiversificationInterpretation:
          "Tu mayor posición, {category}, representa el {largestWeight}% de la cartera — eso es como tener solo {effectiveAssets} activos igualmente distribuidos.",
      AppStrings.labDiversificationConcentrationShockButton:
          "La mayor posición cae 30%",
      AppStrings.labDiversificationMarketShockButton: "Todo cae 15%",
      AppStrings.labDiversificationConcentrationShockResult:
          "Si {category} cayera 30%, tu cartera perdería el {impact}% del valor total — cuanto mayor la posición, mayor el golpe.",
      AppStrings.labDiversificationMarketShockResult:
          "Si todas las categorías cayeran 15% al mismo tiempo, tu cartera perdería 15% — ese número siempre es el mismo, sin importar cómo distribuiste el dinero.",
      AppStrings.labDiversificationSafetyDisclaimer:
          "Diversificar reduce el riesgo de concentración en un solo activo, pero no elimina el riesgo del mercado en general — una cartera diversificada no es lo mismo que una cartera sin riesgo.",
      AppStrings.labDiversificationQuestion: "Diversificar protege contra…",
      AppStrings.labDiversificationOptionA:
          "Riesgo de concentración en un solo activo",
      AppStrings.labDiversificationOptionB: "Cualquier caída del mercado",
      AppStrings.labDiversificationOptionC: "Todas las pérdidas posibles",
      AppStrings.labDiversificationAnswerExplanation:
          "La diversificación reduce cuánto puede afectarte una sola posición, pero cuando cae todo el mercado, una cartera diversificada también siente el impacto.",
      AppStrings.labPortfolioSubtitle:
          "Arma una cartera hipotética y prueba escenarios de mercado.",
      AppStrings.labPortfolioTotalAmountLabel: "Valor total simulado",
      AppStrings.labPortfolioNewValueLabel: "Valor tras el escenario",
      AppStrings.labPortfolioDeltaLabel: "Variación",
      AppStrings.labPortfolioIntro:
          "Arma una cartera hipotética, elige un escenario y mira cómo su composición cambia la respuesta de la cartera — sin afectar tu cartera real.",
      AppStrings.labPortfolioSandboxDisclaimer:
          "Esta es una cartera hipotética de laboratorio — nada aquí afecta tu Cartera real.",
      AppStrings.labPortfolioForecastDisclaimer:
          "Estos escenarios son simulaciones educativas y no predicen retornos futuros.",
      AppStrings.labPortfolioScenarioEquitiesDown15: "Las acciones caen 15%",
      AppStrings.labPortfolioScenarioLargestPositionDown20:
          "La mayor posición cae 20%",
      AppStrings.labPortfolioScenarioBroadMarketDown10: "Todo cae 10%",
      AppStrings.labPortfolioScenarioFixedIncomeUp5: "Renta Fija sube 5%",
      AppStrings.labPortfolioScenarioResult:
          "Bajo este escenario, tu cartera simulada cambiaría {deltaPercent}%, de {before} a {after} — la cartera reacciona de forma distinta a cualquier activo aislado.",
      AppStrings.labPortfolioQuestion:
          "¿Por qué el impacto de un escenario en toda la cartera suele diferir del impacto en un solo activo?",
      AppStrings.labPortfolioOptionA:
          "Porque la cartera combina activos con pesos diferentes",
      AppStrings.labPortfolioOptionB:
          "Porque todos los activos siempre se mueven juntos",
      AppStrings.labPortfolioOptionC: "Porque la cartera ignora los escenarios",
      AppStrings.labPortfolioAnswerExplanation:
          "El impacto total es la suma ponderada del impacto en cada categoría — por eso la cartera en conjunto reacciona de una forma que ningún activo aislado refleja por sí solo.",

      AppStrings.appBarPlayerNamedGreeting: "{petName} · Nivel {level}",
      AppStrings.appBarPlayerGenericGreeting: "Nivel {level} · Explorador",
      AppStrings.profileTooltip: "Perfil",
      AppStrings.notificationsTooltip: "Notificaciones",
      AppStrings.logoutTooltip: "Salir",
      AppStrings.navHome: "Inicio",
      AppStrings.navWallet: "Cartera",
      AppStrings.navPassiveIncome: "Ingresos",
      AppStrings.navAcademy: "Academia",
      AppStrings.navMentor: "Mentor",
      AppStrings.homeContinueLearningEyebrow: "Misión de hoy",
      AppStrings.homeContinueLearningCta: "Continuar Aprendiendo",
      AppStrings.homeAllLessonsCompleteTitle: "¡Completaste todo por aquí!",
      AppStrings.homeAllLessonsCompleteBody:
          "Nuevos módulos llegan pronto. Explora la Academia para repasar lo que ya aprendiste.",
      AppStrings.homeExploreAcademyCta: "Ver Academia",
      AppStrings.homeLevelProgressLabel: "XP para el próximo nivel",
      AppStrings.homeNextEvolutionLabel: "XP para la próxima evolución",
      AppStrings.homeMaxEvolutionLabel: "Evolución máxima alcanzada",
      AppStrings.homeKnowledgeMapLabel: "TU RUTA DE CONOCIMIENTO",
      AppStrings.homeViewFullAcademyCta: "Ver ruta completa",
      AppStrings.homePortfolioBridgeLabel: "TU CARTERA",
      AppStrings.homePortfolioBridgeApplyMessage:
          "Ya completaste {count} lecciones — mira cómo aplicar ese conocimiento en tu cartera real.",
      AppStrings.homeViewPortfolioCta: "Ver Cartera",
      AppStrings.homeAnswerInvestorProfileLink:
          "¿Aún no respondiste tu perfil de riesgo? Responder ahora",
      AppStrings.homeMissionAlmostDoneEyebrow: "Casi listo",
      AppStrings.homeMissionAlmostDoneBody:
          "Falta 1 lección para completar esta misión y ganar +{xp} XP.",
      AppStrings.levelTierBeginner: "Principiante",
      AppStrings.levelTierLearner: "Aprendiz",
      AppStrings.levelTierExplorer: "Explorador",
      AppStrings.levelTierInvestor: "Inversor",
      AppStrings.levelTierAnalyst: "Analista",
      AppStrings.levelTierStrategist: "Estratega",
      AppStrings.levelTierSpecialist: "Especialista",

      // Knowledge Progress tiers (curriculum completion, not XP)
      AppStrings.knowledgeLevelAbsoluteBeginner: "Principiante Absoluto",
      AppStrings.knowledgeLevelFinancialApprentice: "Aprendiz Financiero",
      AppStrings.knowledgeLevelFinancialOrganizer: "Organizador Financiero",
      AppStrings.knowledgeLevelFinancialProtector: "Protector Financiero",
      AppStrings.knowledgeLevelBeginnerInvestor: "Inversor Principiante",
      AppStrings.knowledgeLevelInvestor: "Inversor",
      AppStrings.knowledgeLevelAnalyst: "Analista",
      AppStrings.knowledgeLevelWealthBuilder: "Constructor de Patrimonio",
      AppStrings.knowledgeLevelFinancialStrategist: "Estratega Financiero",
      AppStrings.knowledgeLevelFinancialMaster: "Maestro Financiero",

      AppStrings.companionHeaderTooltip: "Abrir tu compañero",
      AppStrings.companionDismissTooltip: "Cerrar",
      AppStrings.companionInteractionTitle: "¿Cómo puedo ayudarte?",
      AppStrings.companionInteractionSubtitle: "Elige a dónde ir",
      AppStrings.companionInteractionLearn: "Aprender",
      AppStrings.companionInteractionPortfolio: "Cartera",
      AppStrings.companionInteractionProgress: "Progreso",
      AppStrings.companionActionContinue: "Continuar",
      AppStrings.companionActionViewPortfolio: "Ver Cartera",
      AppStrings.companionActionViewProgress: "Ver Progreso",
      AppStrings.companionHomeXpToNextLevel:
          "¡Solo {xp} XP para tu próximo nivel!",
      AppStrings.companionAcademyContinueLesson:
          "Estabas avanzando en \"{lessonTitle}\". ¿Continuar donde lo dejaste?",
      AppStrings.companionAcademyReviewDue:
          "Tienes {count} conceptos para repasar. ¿Reforzamos lo que ya aprendiste?",
      AppStrings.companionPortfolioDiversified:
          "Tu cartera está distribuida en {count} activos diferentes.",
      AppStrings.companionMentorNudge:
          "¿Tienes alguna duda sobre inversiones? Pregúntame lo que quieras.",
      AppStrings.companionProfileSummary:
          "Estás en el nivel {level} — {stage}.",
      AppStrings.companionEventLessonCompleted:
          "¡Muy bien! Completaste la lección.",
      AppStrings.companionEventXpGained: "¡+{xp} XP! Sigue así.",
      AppStrings.companionEventLevelUp:
          "¡Nivel {level} alcanzado! Estoy orgulloso de ti.",
      AppStrings.companionEventAchievementUnlocked:
          "¡Logro desbloqueado: {title}!",
      AppStrings.companionEventEvolved: "¡Evolucioné! Ahora soy {stage}.",
      AppStrings.companionEventDifficultyDetected:
          "Noté que fallaste algunas en {school}. ¿Repasamos juntos?",
      AppStrings.companionEventSchoolMastered:
          "¡Completaste todo lo disponible en {school}! ¡Muy bien!",
      AppStrings.companionEventFirstInvestment:
          "¡Esa fue tu primera inversión! ¿Quieres entender mejor lo que acabas de agregar a tu cartera?",
      AppStrings.companionEventHighConcentration:
          "Noté que {ticker} representa el {percent}% de tu cartera. ¿Quieres entender por qué diversificar puede reducir el riesgo?",
      AppStrings.companionPortfolioActivationNudge:
          "Todo camino de inversor empieza con el primer paso. Estoy aquí cuando quieras dar el tuyo.",
      AppStrings.companionInvestorStatusYes:
          "¡Genial! Vamos a empezar registrando tu primera inversión.",
      AppStrings.companionInvestorStatusNo:
          "¡No hay problema! No necesitas inversiones para empezar tu camino.",
      AppStrings.companionActionUnderstand: "Entender",
      AppStrings.companionHomeMotivation1:
          "Cada pequeño paso te deja más preparado para el futuro. ¡Sigue así!",
      AppStrings.companionHomeMotivation2:
          "Invertir es una maratón, no una carrera. Tu constancia ya es un logro.",
      AppStrings.companionHomeMotivation3:
          "Estás construyendo un hábito que valdrá la pena. Estoy orgulloso de acompañarte en este camino.",
      AppStrings.companionHomeMotivation4:
          "Aprender sobre dinero es una de las mejores inversiones que puedes hacer. ¿Seguimos?",
      AppStrings.companionHomeMotivation5:
          "Cada día que vuelves aquí es un día más cerca de tus objetivos.",
      AppStrings.companionHomeReturnGreeting1:
          "¡Qué bueno verte de nuevo! ¿Seguimos donde lo dejamos?",
      AppStrings.companionHomeReturnGreeting2:
          "¡Me alegra que volvieras! Tu viaje todavía te espera.",
      AppStrings.companionHomeMissionAlmostDone:
          "¡Estás a una lección de completar '{missionTitle}'!",
      AppStrings.companionEventMissionCompleted:
          "¡Misión completa: {title}! Un paso más hacia un inversor más seguro.",
      AppStrings.companionEventLabSimulatorCompleted:
          "¡Completaste el simulador de {simulator}! Eso es entender de inversiones en la práctica.",

      AppStrings.forgotPasswordTitle: "Recuperar contraseña",
      AppStrings.forgotPasswordSubtitle:
          "Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.",
      AppStrings.forgotPasswordEmailHint: "Tu correo",
      AppStrings.forgotPasswordSendButton: "Enviar enlace",
      AppStrings.forgotPasswordConfirmationMessage:
          "Si existe una cuenta con ese correo, recibirás instrucciones en unos instantes.",
      AppStrings.forgotPasswordHaveCodeLink:
          "Ya tengo un código de restablecimiento",
      AppStrings.resetPasswordTitle: "Restablecer contraseña",
      AppStrings.resetPasswordSubtitle:
          "Pega el código que te enviamos por correo y elige una nueva contraseña.",
      AppStrings.resetPasswordTokenHint: "Código de restablecimiento",
      AppStrings.resetPasswordNewPasswordHint: "Nueva contraseña",
      AppStrings.resetPasswordSubmitButton: "Restablecer contraseña",
      AppStrings.resetPasswordSuccessMessage:
          "¡Contraseña restablecida con éxito! Inicia sesión con tu nueva contraseña.",
      AppStrings.resetPasswordMismatchError: "Las contraseñas no coinciden.",
      AppStrings.resetPasswordFieldsRequiredError: "Completa todos los campos.",

      AppStrings.wealthLegendPatrimony: "Patrimonio",
      AppStrings.wealthLegendInvested: "Invertido",
      AppStrings.wealthLegendAppliedValue: "Valor invertido",
      AppStrings.wealthLegendCapitalGain: "Ganancia de Capital",
      AppStrings.proventosLegendReceived: "Recibidos",
      AppStrings.proventosLegendExpected: "Por recibir",
      AppStrings.noAssetsRegisteredYet: "Ningún activo registrado todavía.",
      AppStrings.retryButtonLabel: "Intentar de nuevo",
      AppStrings.errorNoConnectionMessage:
          "No se pudo conectar. Verifica tu conexión a internet e inténtalo de nuevo.",
      AppStrings.errorUnexpectedMessage:
          "Ocurrió algo inesperado. Inténtalo de nuevo.",
      AppStrings.mentorNewChatTooltip: "Nueva conversación",
      AppStrings.mentorHistoryTooltip: "Historial",
      AppStrings.mentorConversationHistoryTitle: "Conversaciones",
      AppStrings.mentorNoConversationsTitle: "Aún no hay conversaciones",
      AppStrings.mentorNoConversationsSubtitle:
          "Tus conversaciones con el mentor aparecerán aquí.",
      AppStrings.mentorConversationsLoadError:
          "No pudimos cargar tus conversaciones.",
      AppStrings.mentorRenameConversationTitle: "Renombrar conversación",
      AppStrings.mentorRenameConversationHint: "Título de la conversación",
      AppStrings.mentorRenameConversationSave: "Guardar",
      AppStrings.mentorRenameConversationFailed:
          "No se pudo renombrar la conversación. Inténtalo de nuevo.",
      AppStrings.mentorDeleteConversationTitle: "¿Borrar conversación?",
      AppStrings.mentorDeleteConversationConfirm:
          "Esta conversación y todos sus mensajes se eliminarán permanentemente.",
      AppStrings.mentorDeleteConversationButton: "Borrar",
      AppStrings.mentorDeleteConversationFailed:
          "No se pudo eliminar la conversación. Inténtalo de nuevo.",
      AppStrings.initialPortfolioTitle: "Portafolio Inicial",
      AppStrings.portfolioCardTitle: "Portafolio",
      AppStrings.profileTitle: "Perfil",
      AppStrings.profileCommanderTitle: "Perfil del Comandante",
      AppStrings.profileAchievementsLabel: "Logros",
      AppStrings.profileAchievementsComingSoonBody:
          "Tus logros e hitos aparecerán aquí a medida que progreses.",
      AppStrings.profileSettingsHint:
          "Gestiona idioma y cuenta en configuración.",
      AppStrings.investorProfileScreenTitle: "Perfil de Riesgo",
      AppStrings.investorProfileScreenSubtitle:
          "Diferente de tu objetivo financiero — esto es sobre cómo te relacionas con el riesgo.",
      AppStrings.investorProfileClearAnswersButton: "Borrar respuestas",
      AppStrings.investorProfileClearAnswers: "Respuestas borradas.",
      AppStrings.petTeacherAskMentor: "Pregúntale al mentor:",
      AppStrings.petTeacherOwnedGreeting:
          "¡Vamos a entender mejor {assetName}!",
      AppStrings.petTeacherNotOwnedGreeting:
          "¿Quieres saber más sobre {assetName}?",
    },
  };

  /// [params] fills `{token}` placeholders in the translated string (e.g.
  /// `{petName}`) — used for copy that embeds the user's chosen pet name,
  /// which can't be baked into the static translation map.
  static String translate(String key, {Map<String, String>? params}) {
    var value =
        _localizedValues[currentLanguage]?[key] ??
        _localizedValues[defaultLanguage]?[key] ??
        key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return value;
  }

  /// Test-only escape hatch onto the private `_localizedValues` map, so
  /// `translator_test.dart` can assert the three language blocks stay
  /// key-parallel (a missing es/en key otherwise silently falls back to pt,
  /// with nothing surfacing the gap — see `docs/DECISIONS.md` DECISION-037).
  /// Not used by app code.
  static Map<String, Map<String, String>> get debugLocalizedValues =>
      _localizedValues;
}
