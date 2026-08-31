import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/dividend_event_tile.dart';

/// Bell-icon notification panel — real, provider-confirmed upcoming dividend
/// / JCP / yield payments for the user's real holdings (the same
/// [DividendEvent] data backing `DividendRadarSection` on the Proventos tab,
/// just surfaced app-wide via the AppBar instead of gated behind that tab).
/// Reuses [DividendEventTile] rather than inventing a second row layout for
/// the same data — matches AI_RULES.md's "reuse before you invent".
class DividendNotificationsSheet extends StatelessWidget {
  const DividendNotificationsSheet({
    super.key,
    required this.isLoading,
    required this.error,
    required this.upcoming,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final List<DividendEvent> upcoming;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: tokens.divider, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notificações · Próximos Proventos',
                    style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pagamentos de dividendos, JCP e rendimentos já confirmados pela B3 para os ativos que você possui.',
              style: TextStyle(color: tokens.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 16),
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final tokens = context.colors;
    if (isLoading && upcoming.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: AppLoadingIndicator(strokeWidth: 2),
      );
    }

    if (error != null && upcoming.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ErrorStateView(
          message: 'Não foi possível carregar suas notificações.',
          onRetry: () async => onRetry(),
          style: ErrorStateStyle.compact,
        ),
      );
    }

    if (upcoming.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.notifications_off_outlined, color: tokens.textTertiary, size: 32),
            const SizedBox(height: 10),
            Text(
              'Nenhum provento confirmado a caminho para os seus ativos no momento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [for (final event in upcoming) DividendEventTile(event: event)],
    );
  }
}
