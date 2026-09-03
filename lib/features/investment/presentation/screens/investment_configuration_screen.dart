import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/financial_input_validators.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';
import 'package:petrimonium/features/investment/domain/services/pending_portfolio_stats_builder.dart';
import 'package:petrimonium/features/investment/domain/services/ticker_type_classifier.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/investment/presentation/widgets/added_asset_tile.dart';
import 'package:petrimonium/features/investment/presentation/widgets/investment_field_style.dart';
import 'package:petrimonium/features/investment/presentation/widgets/investment_type_selector.dart';
import 'package:petrimonium/features/investment/presentation/widgets/live_portfolio_summary_card.dart';
import 'package:petrimonium/features/investment/presentation/widgets/pet_companion_card.dart';
import 'package:petrimonium/features/investment/presentation/widgets/portfolio_progress_bar.dart';
import 'package:petrimonium/features/investment/presentation/widgets/ticker_suggestion_tile.dart';
import 'package:petrimonium/features/investment/presentation/widgets/unlockable_rewards_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

class InvestmentConfigurationScreen extends StatefulWidget {
  const InvestmentConfigurationScreen({super.key});

  @override
  State<InvestmentConfigurationScreen> createState() => _InvestmentConfigurationScreenState();
}

class _InvestmentConfigurationScreenState extends State<InvestmentConfigurationScreen> {
  final List<AssetRegistrationModel> _assets = [];
  bool _isLoading = false;

  /// Index being edited (see `_editAsset`) — when set, the next successful
  /// `_addAsset` re-inserts at this position instead of appending, so
  /// editing doesn't reorder the list.
  int? _editingIndex;

  /// Achievements already unlocked in previous sessions, loaded once so the
  /// live summary only counts genuinely *new* rewards this session would
  /// grant — not ones the user already has.
  Set<String> _alreadyUnlockedIds = {};

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  InvestmentTypeEnum? _selectedType;
  DateTime? _selectedDate;

  static const int _starterPortfolioTarget = 3;

  PortfolioStats get _pendingStats => PendingPortfolioStatsBuilder.build(_assets);

  @override
  void initState() {
    super.initState();
    _loadAchievementBaseline();
    _seedExistingHoldings();
  }

  Future<void> _loadAchievementBaseline() async {
    try {
      final unlocked = await DI.achievementsLocalRepository.loadUnlocked();
      if (mounted) setState(() => _alreadyUnlockedIds = unlocked.keys.toSet());
    } catch (_) {
      // Best-effort only — worst case the "already unlocked" baseline stays
      // empty and a celebration that should've been skipped shows anyway.
    }
  }

  /// `POST /configure` replaces the user's entire portfolio with whatever
  /// `_assets` holds at confirm time — it's an onboarding-style "set my
  /// portfolio" call, not an append. This screen is also opened from the
  /// Portfolio tab's "Investir" action for users who already have holdings,
  /// so without this seeding, adding one new asset there would submit only
  /// that asset and wipe every existing investment. Loading is best-effort:
  /// a failure here just leaves this a normal empty-start onboarding form.
  Future<void> _seedExistingHoldings() async {
    try {
      final holdings = await DI.portfolioRepository.fetchHoldings();
      final existing = holdings
          .expand((holding) => holding.lots)
          .map((lot) => AssetRegistrationModel(
                name: lot.ticker,
                quantity: lot.quantity,
                purchasePrice: lot.purchasePrice,
                purchaseDate: _formatDate(lot.purchaseDate),
                type: lot.type,
              ))
          .toList();
      if (mounted && existing.isNotEmpty) {
        setState(() => _assets.insertAll(0, existing));
      }
    } catch (_) {
      // Best-effort — see doc comment above.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Blocks saving a ticker under the wrong type card — e.g. entering
  /// `HGLG11` (a FII) while "Renda Fixa" is selected. Only fires when the
  /// ticker's suffix strongly implies a specific type; free-text names
  /// (Renda Fixa, crypto, "Outros") and ambiguous B3 suffixes (BDRs, ETFs,
  /// units) are never second-guessed — see [TickerTypeClassifier].
  String? _tickerTypeMismatch(String? tickerText) {
    if (_selectedType == null || tickerText == null || tickerText.isEmpty) return null;
    final detected = TickerTypeClassifier.classify(tickerText);
    if (detected == null || detected == _selectedType) return null;
    return 'Esse ticker parece ser ${detected.label}, não ${_selectedType!.label}.';
  }

  String _formatNum(double value) => value.truncateToDouble() == value ? value.toInt().toString() : value.toString();

  void _addAsset() {
    // Field-level validators (name required, quantity/price must be valid
    // positive numbers — see FinancialInputValidators) already show their
    // own message under the field; a failure here means one of those.
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null || _selectedDate == null) {
      GameSnack.show(
        context,
        _selectedType == null ? 'Selecione um tipo de ativo.' : 'Selecione uma data de compra.',
        isError: true,
      );
      return;
    }

    // Never fall back to 0.0 for malformed input — the validators above
    // already guarantee these parse to a valid, positive number, so a null
    // here would mean the form validated something it shouldn't have.
    final quantity = FinancialInputValidators.parsePositiveDecimal(_quantityController.text);
    final price = FinancialInputValidators.parsePositiveDecimal(_priceController.text);
    if (quantity == null || price == null) return;

    final asset = AssetRegistrationModel(
      name: _nameController.text,
      quantity: quantity,
      purchasePrice: price,
      purchaseDate: _formatDate(_selectedDate!),
      type: _selectedType!,
    );

    final wasEditing = _editingIndex != null;

    setState(() {
      if (_editingIndex != null) {
        _assets.insert(_editingIndex!.clamp(0, _assets.length), asset);
        _editingIndex = null;
      } else {
        _assets.add(asset);
      }
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _selectedType = null;
      _selectedDate = null;
    });

    if (!wasEditing) _showAddFeedback(_assets.length);
  }

  void _showAddFeedback(int newCount) {
    if (newCount == 1) {
      GameSnack.showWithHaptic(
        context,
        '🎉 Primeiro investimento adicionado! Você começou sua jornada.',
        isSuccess: true,
      );
    } else if (newCount == _starterPortfolioTarget) {
      GameSnack.showWithHaptic(
        context,
        '🚀 Portfólio inicial completo! Você está pronto para continuar.',
        isSuccess: true,
      );
    } else {
      GameSnack.showWithHaptic(context, '✨ Ativo adicionado! Seu portfólio está crescendo.', isSuccess: true);
    }
  }

  void _editAsset(int index) {
    final asset = _assets[index];
    setState(() {
      _editingIndex = index;
      _assets.removeAt(index);
      _nameController.text = asset.name;
      _quantityController.text = _formatNum(asset.quantity);
      _priceController.text = _formatNum(asset.purchasePrice);
      _selectedType = asset.type;
      _selectedDate = DateTime.tryParse(asset.purchaseDate);
    });
  }

  void _removeAsset(int index) {
    setState(() {
      _assets.removeAt(index);
      if (_editingIndex != null && _editingIndex! >= index) {
        _editingIndex = null;
      }
    });
  }

  void _reorderAssets(int oldIndex, int newIndex) {
    setState(() {
      final item = _assets.removeAt(oldIndex);
      _assets.insert(newIndex, item);
    });
  }

  String get _confirmLabel {
    if (_assets.isEmpty) return 'Adicione um ativo para continuar';
    if (_assets.length < _starterPortfolioTarget) {
      final plural = _assets.length == 1 ? 'ativo adicionado' : 'ativos adicionados';
      return 'Continuar (${_assets.length} $plural)';
    }
    return 'Portfólio Pronto ✓';
  }

  Future<void> _handleConfirm() async {
    if (_assets.isEmpty) {
      GameSnack.show(context, 'Adicione pelo menos um ativo para continuar.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.investmentRepository.configureInvestments(_assets);
      await DI.onboardingStateRepository.markPortfolioConnected();
      if (mounted) _goHome();
    } catch (e) {
      if (mounted) {
        GameSnack.show(context, 'Falha ao salvar investimentos: ${friendlyErrorMessage(e)}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSkip() async {
    await DI.onboardingStateRepository.markPortfolioSkipped();
    if (mounted) _goHome();
  }

  /// Clears the entire navigator stack (including any onboarding screens
  /// still underneath) so the back button never leads back into onboarding
  /// once the user has reached Home.
  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonCyan,
              onPrimary: Colors.black,
              surface: AppColors.spaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await _refreshPriceForSelectedDate();
    }
  }

  /// Re-fetches the ticker's historical price so editing the purchase date
  /// keeps the price field truthful to that date, the same way selecting a
  /// ticker from autocomplete fills in its current price.
  Future<void> _refreshPriceForSelectedDate() async {
    final ticker = _nameController.text.trim();
    if (ticker.isEmpty || _selectedDate == null) return;

    final quote = await DI.investmentRepository.fetchQuoteAtDate(ticker, _formatDate(_selectedDate!));
    final price = quote?['regularMarketPrice'];
    if (price != null && mounted) {
      setState(() => _priceController.text = price.toString());
    }
  }

  Widget _buildAutocompleteField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Autocomplete<Map<String, dynamic>>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.length < 2) {
            return const Iterable<Map<String, dynamic>>.empty();
          }
          final results = await DI.investmentRepository.searchQuotes(textEditingValue.text);
          if (_selectedType == null) return results;
          return results.where((option) {
            final symbol = (option['symbol'] ?? option['stock'] ?? '').toString();
            final detected = TickerTypeClassifier.classify(symbol);
            return detected == null || detected == _selectedType;
          });
        },
        displayStringForOption: (Map<String, dynamic> option) {
          return option['symbol']?.toString() ?? option['stock']?.toString() ?? '';
        },
        onSelected: (Map<String, dynamic> selection) {
          final symbol = selection['symbol']?.toString() ?? selection['stock']?.toString() ?? '';
          setState(() {
            _nameController.text = symbol;
            _priceController.text = selection['regularMarketPrice']?.toString() ?? selection['close']?.toString() ?? '';
            // Only fill in a type the user hasn't picked yet — never override
            // an explicit selection, and leave it untouched when the ticker
            // is ambiguous (BDR/ETF-39/unit/free text) so they still choose.
            _selectedType ??= TickerTypeClassifier.classify(symbol);
            _formKey.currentState?.validate();
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          controller.addListener(() {
            _nameController.text = controller.text;
          });

          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: investmentInputDecoration(context, label: 'Nome/Ticker (ex: PETR4)'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo obrigatório';
              return _tickerTypeMismatch(value);
            },
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              elevation: 4.0,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 280, maxWidth: 320),
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated.withValues(alpha: context.isDarkMode ? 0.97 : 0.96),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    final symbol = (option['symbol'] ?? option['stock'] ?? '').toString();
                    final name = (option['shortName'] ?? option['name'] ?? '').toString();
                    final priceRaw = option['regularMarketPrice'] ?? option['close'];
                    final price = priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw?.toString() ?? '');
                    return TickerSuggestionTile(
                      symbol: symbol,
                      name: name,
                      price: price,
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type, {
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: context.colors.textPrimary),
        decoration: investmentInputDecoration(context, label: label, suffixIcon: suffixIcon),
        validator: validator ?? (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GestureDetector(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: investmentFieldFill(context),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: investmentFieldBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'Data de Compra'
                      : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                  style: AppTextStyles.title.copyWith(
                    color: _selectedDate == null ? context.colors.textSecondary : context.colors.textPrimary,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.calendar_today, color: AppColors.neonCyan),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(Translator.translate(AppStrings.initialPortfolioTitle), style: TextStyle(color: context.colors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_nebula.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 4, child: _buildLeftPanel()),
                          const SizedBox(width: 32),
                          Expanded(flex: 6, child: _buildRightPanel()),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 520, child: _buildLeftPanel()),
                            const SizedBox(height: 16),
                            SizedBox(height: 720, child: _buildRightPanel()),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    final stats = _pendingStats;

    return GlassCard(
      isAnimated: true,
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.4 : 0.94),
      borderRadius: AppRadii.xxl,
      borderColor: AppColors.neonCyan.withValues(alpha: 0.5),
      borderWidth: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Monte seu Portfólio',
              style: AppTextStyles.display.copyWith(color: context.colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Cada grande investidor começou com um único investimento. Sua jornada financeira começa agora.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyEmphasis.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.normal, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            PetCompanionCard(assetCount: _assets.length),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: UnlockableRewardsCard(stats: stats),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PortfolioProgressBar(assetCount: _assets.length, target: _starterPortfolioTarget),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    final stats = _pendingStats;

    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
      borderRadius: AppRadii.xxl,
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.2),
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Adicionar Ativo',
              style: AppTextStyles.headline.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      InvestmentTypeSelector(
                        selected: _selectedType,
                        onChanged: (type) => setState(() {
                          _selectedType = type;
                          _formKey.currentState?.validate();
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildAutocompleteField(),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _quantityController,
                              'Qtd.',
                              const TextInputType.numberWithOptions(decimal: true),
                              validator: FinancialInputValidators.quantity,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              _priceController,
                              'Preço (R\$)',
                              const TextInputType.numberWithOptions(decimal: true),
                              validator: FinancialInputValidators.price,
                            ),
                          ),
                        ],
                      ),
                      _buildDatePickerField(),
                      const SizedBox(height: 4),
                      GameButton(
                        label: _editingIndex != null ? 'Salvar Alteração' : 'Adicionar Ativo',
                        icon: _editingIndex != null ? Icons.check : Icons.add,
                        colors: const [AppColors.spaceBlue, AppColors.neonCyan],
                        height: 52,
                        onPressed: _addAsset,
                      ),
                      const SizedBox(height: 20),
                      LivePortfolioSummaryCard(stats: stats, alreadyUnlockedIds: _alreadyUnlockedIds),
                      const SizedBox(height: 16),
                      if (_assets.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ativos Adicionados',
                            style: AppTextStyles.title.copyWith(color: context.colors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _assets.length,
                          onReorder: _reorderAssets,
                          itemBuilder: (context, index) {
                            final asset = _assets[index];
                            return AddedAssetTile(
                              key: ObjectKey(asset),
                              index: index,
                              asset: asset,
                              onEdit: () => _editAsset(index),
                              onRemove: () => _removeAsset(index),
                            );
                          },
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md + 2),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: AppColors.goldenBorder, size: 18),
                              const SizedBox(width: AppSpacing.sm + 2),
                              Expanded(
                                child: Text(
                                  'Dica: você pode registrar compras antigas — a data de compra ajuda a calcular seu retorno real.',
                                  style: AppTextStyles.label.copyWith(color: context.colors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GameButton(
              label: _confirmLabel,
              icon: _assets.isNotEmpty ? Icons.arrow_forward : null,
              iconTrailing: true,
              isLoading: _isLoading,
              pulse: _assets.isNotEmpty,
              height: 56,
              onPressed: _assets.isEmpty ? null : _handleConfirm,
            ),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : _handleSkip,
                child: Text(
                  Translator.translate(AppStrings.skipForNowButton),
                  style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
