import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/asset_details/presentation/screens/asset_details_screen.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/performance_badge.dart';

/// One holding row inside an [ExpandableCategory]. There's no logo CDN or
/// company-name/fundamentals feed in this app's data model (the backend
/// only persists a ticker string per lot), so the "logo" is a generated
/// ticker-initial avatar rather than a fabricated brand image.
class AssetRow extends StatelessWidget {
  const AssetRow({super.key, required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isPositive = holding.gainValue >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AssetDetailsScreen(ticker: holding.ticker, holding: holding),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              _TickerAvatar(ticker: holding.ticker, color: holding.type.color),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.ticker,
                      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      '${holding.quantity.toStringAsFixed(holding.quantity.truncateToDouble() == holding.quantity ? 0 : 2)} un · PM ${AppFormatters.currency(holding.averagePrice)}',
                      style: TextStyle(color: tokens.textSecondary, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.currency(holding.currentValue, showCents: false),
                      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      '${holding.portfolioPercent.toStringAsFixed(1)}% carteira',
                      style: TextStyle(color: tokens.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PerformanceBadge(percent: holding.gainPercent, compact: true),
              const SizedBox(width: 2),
              Icon(
                isPositive ? Icons.chevron_right : Icons.chevron_right,
                color: tokens.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TickerAvatar extends StatelessWidget {
  const _TickerAvatar({required this.ticker, required this.color});

  final String ticker;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initials = ticker.length >= 2 ? ticker.substring(0, 2) : ticker;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
