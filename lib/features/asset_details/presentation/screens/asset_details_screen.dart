import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petrimonium/features/asset_details/presentation/controllers/asset_details_controller.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/allocation_suggestion_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/applied_learning_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_education_section.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_header.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_valuation_chart_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/concentration_warning.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/dividend_history_section.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/key_indicators_section.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/pet_teacher_widget.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/portfolio_context_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/purchase_history_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/user_position_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';

/// Full-screen asset details page — the core of the Real Asset Intelligence
/// feature. Replaces the previous [AssetDetailsSheet] bottom sheet with a
/// full-screen, scrollable, educational experience.
///
/// Opens instantly with cached [Holding] data, then enriches from the backend.
/// The layout dynamically adapts to the asset type (stock/FII/ETF).
class AssetDetailsScreen extends StatefulWidget {
  const AssetDetailsScreen({
    super.key,
    required this.ticker,
    this.holding,
  });

  final String ticker;
  final Holding? holding;

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  late final AssetDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AssetDetailsController(
      repository: DI.assetDetailsRepository,
    );
    _controller.addListener(_onUpdate);
    _controller.loadAssetDetails(widget.ticker, holding: widget.holding);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      backgroundColor: tokens.backgroundPrimary,
      body: Container(
        decoration: context.isDarkMode
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.spaceDark, AppColors.spacePurple, AppColors.spaceBlue],
                ),
              )
            : BoxDecoration(color: tokens.backgroundPrimary),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final asset = _controller.assetDetails;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textPrimary, size: 20),
          ),
          Expanded(
            child: Text(
              asset?.ticker ?? widget.ticker,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Data status indicator
          _DataStatusBadge(status: asset?.dataStatus ?? AssetDataStatus.unavailable),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final asset = _controller.assetDetails;

    if (_controller.isLoading && asset == null) {
      return const _AssetDetailsSkeleton();
    }

    if (_controller.error != null && asset == null) {
      return ErrorStateView(
        title: 'Não foi possível carregar este ativo',
        message: _controller.error!,
        onRetry: _controller.refresh,
      );
    }

    if (asset == null) {
      return Center(
        child: Text(
          'Ativo não encontrado.',
          style: TextStyle(color: context.colors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: context.colors.surfaceElevated,
      onRefresh: _controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // ── Header: ticker, name, price, change ─────────────
          AssetHeader(asset: asset),

          const SizedBox(height: 16),

          // ── User Position (if owned) ────────────────────────
          if (asset.isOwned) ...[
            UserPositionCard(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Valuation chart & purchase history — only available with the
          // real Holding (lots), not the plain backend AssetDetails entity;
          // widget.holding is null for a route that opens by ticker alone.
          if (widget.holding != null) ...[
            AssetValuationChartCard(holding: widget.holding!),
            const SizedBox(height: 16),
          ],

          // ── Key Indicators (type-aware) ─────────────────────
          KeyIndicatorsSection(asset: asset),

          const SizedBox(height: 16),

          // ── Portfolio Context (if owned) ─────────────────────
          if (asset.isOwned) ...[
            PortfolioContextCard(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Concentration Warning (if concentrated) ─────────
          if (asset.isOwned && _isConcentrated(asset)) ...[
            ConcentrationWarning(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Allocation suggestion (target vs. real weight) ──
          if (widget.holding != null) ...[
            AllocationSuggestionCard(holding: widget.holding!),
            const SizedBox(height: 16),
          ],

          // ── Apply What You Learned (Educational Portfolio Intelligence) ──
          if (asset.isOwned && _controller.appliedConcepts.isNotEmpty) ...[
            AppliedLearningCard(asset: asset, appliedConcepts: _controller.appliedConcepts),
            const SizedBox(height: 16),
          ],

          // ── Dividend History ─────────────────────────────────
          if (asset.recentDividends.isNotEmpty) ...[
            DividendHistorySection(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Purchase History (lot by lot) ────────────────────
          if (widget.holding != null && widget.holding!.lots.isNotEmpty) ...[
            PurchaseHistoryCard(holding: widget.holding!),
            const SizedBox(height: 16),
          ],

          // ── Educational Section ─────────────────────────────
          AssetEducationSection(asset: asset),

          const SizedBox(height: 16),

          // ── Pet Teacher ─────────────────────────────────────
          PetTeacherWidget(asset: asset),

          // ── Loading indicator for background refresh ────────
          if (_controller.isLoading && asset.dataStatus == AssetDataStatus.cached)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neonCyan,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isConcentrated(dynamic asset) {
    return asset.userPosition != null && asset.userPosition!.portfolioWeight > 20;
  }
}

// ── Data Status Badge ───────────────────────────────────────────────────

class _DataStatusBadge extends StatelessWidget {
  const _DataStatusBadge({required this.status});

  final AssetDataStatus status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final (color, label) = switch (status) {
      AssetDataStatus.fresh => (tokens.success, 'Ao vivo'),
      AssetDataStatus.cached => (tokens.warning, 'Cache'),
      AssetDataStatus.delayed => (tokens.warning, 'Atrasado'),
      AssetDataStatus.partial => (tokens.warning, 'Parcial'),
      AssetDataStatus.unavailable => (tokens.error, 'Indisponível'),
      AssetDataStatus.error => (tokens.error, 'Erro'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────

class _AssetDetailsSkeleton extends StatelessWidget {
  const _AssetDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _bar(context, height: 120),
        const SizedBox(height: 16),
        _bar(context, height: 100),
        const SizedBox(height: 16),
        _bar(context, height: 80),
        const SizedBox(height: 16),
        _bar(context, height: 140),
      ],
    );
  }

  Widget _bar(BuildContext context, {required double height}) {
    final tokens = context.colors;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
    );
  }
}
