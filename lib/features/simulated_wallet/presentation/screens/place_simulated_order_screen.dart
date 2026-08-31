import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/asset_quote.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order_side.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/controllers/simulated_wallet_controller.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/widgets/simulation_disclaimer_banner.dart';

/// Search a ticker, pick buy/sell, enter a quantity, and confirm a simulated
/// order at the current reference price — the price is always fetched from
/// the backend right before confirming, never entered by the user, so the
/// fill always matches what the server will actually execute at.
class PlaceSimulatedOrderScreen extends StatefulWidget {
  const PlaceSimulatedOrderScreen({super.key, required this.controller});

  final SimulatedWalletController controller;

  @override
  State<PlaceSimulatedOrderScreen> createState() => _PlaceSimulatedOrderScreenState();
}

class _PlaceSimulatedOrderScreenState extends State<PlaceSimulatedOrderScreen> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  Timer? _debounce;

  List<AssetQuote> _results = [];
  bool _isSearching = false;
  AssetQuote? _selected;
  SimulatedOrderSide _side = SimulatedOrderSide.buy;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    setState(() => _selected = null);
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    final results = await widget.controller.searchQuotes(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  void _selectAsset(AssetQuote quote) {
    HapticFeedback.selectionClick();
    setState(() {
      _selected = quote;
      _results = [];
      _searchController.text = quote.symbol;
    });
  }

  Future<void> _confirm() async {
    final selected = _selected;
    if (selected == null) {
      GameSnack.show(context, Translator.translate(AppStrings.simulatedOrderSelectAssetFirst), isError: true);
      return;
    }
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (quantity == null || quantity <= 0) {
      GameSnack.show(context, Translator.translate(AppStrings.simulatedOrderQuantityLabel), isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();
    final order = await widget.controller.placeOrder(
      ticker: selected.symbol,
      side: _side,
      quantity: quantity,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (order != null) {
      GameSnack.show(context, Translator.translate(AppStrings.simulatedOrderSuccessMessage), isSuccess: true);
      Navigator.of(context).pop();
    } else if (widget.controller.orderError != null) {
      GameSnack.show(context, widget.controller.orderError!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(Translator.translate(AppStrings.simulatedOrderScreenTitle)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SimulationDisclaimerBanner(),
          const SizedBox(height: AppSpacing.md),
          _SideToggle(
            selected: _side,
            onChanged: (side) => setState(() => _side = side),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              hintText: Translator.translate(AppStrings.simulatedOrderSearchHint),
              prefixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
            ),
          ),
          if (_results.isNotEmpty)
            GlassCard(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              child: Column(
                children: [
                  for (final quote in _results)
                    ListTile(
                      title: Text(quote.symbol, style: TextStyle(color: tokens.textPrimary)),
                      subtitle: quote.shortName == null ? null : Text(quote.shortName!),
                      trailing: quote.regularMarketPrice == null
                          ? null
                          : Text('R\$ ${quote.regularMarketPrice!.toStringAsFixed(2)}'),
                      onTap: () => _selectAsset(quote),
                    ),
                ],
              ),
            ),
          if (_selected != null) ...[
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selected!.symbol, style: AppTextStyles.titleLarge.copyWith(color: tokens.textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${Translator.translate(AppStrings.simulatedOrderReferencePriceLabel)}: '
                    '${_selected!.regularMarketPrice == null ? '—' : 'R\$ ${_selected!.regularMarketPrice!.toStringAsFixed(2)}'}',
                    style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: Translator.translate(AppStrings.simulatedOrderQuantityLabel),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _confirm,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(Translator.translate(AppStrings.simulatedOrderConfirmAction)),
          ),
        ],
      ),
    );
  }
}

class _SideToggle extends StatelessWidget {
  const _SideToggle({required this.selected, required this.onChanged});

  final SimulatedOrderSide selected;
  final ValueChanged<SimulatedOrderSide> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return SegmentedButton<SimulatedOrderSide>(
      segments: [
        ButtonSegment(
          value: SimulatedOrderSide.buy,
          label: Text(Translator.translate(AppStrings.simulatedOrderBuyLabel)),
          icon: const Icon(Icons.arrow_upward),
        ),
        ButtonSegment(
          value: SimulatedOrderSide.sell,
          label: Text(Translator.translate(AppStrings.simulatedOrderSellLabel)),
          icon: const Icon(Icons.arrow_downward),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
      style: SegmentedButton.styleFrom(selectedForegroundColor: tokens.primary),
    );
  }
}
