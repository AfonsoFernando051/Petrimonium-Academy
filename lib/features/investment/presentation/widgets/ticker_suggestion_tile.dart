import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// One row in the ticker-search autocomplete dropdown — an avatar (ticker
/// initials, since this app has no company-logo CDN), the company name and
/// its current price, so the user recognizes the right result at a glance
/// instead of matching a bare ticker string.
class TickerSuggestionTile extends StatelessWidget {
  const TickerSuggestionTile({super.key, required this.symbol, required this.name, required this.price, required this.onTap});

  final String symbol;
  final String name;
  final double? price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = symbol.length >= 2 ? symbol.substring(0, 2) : symbol;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonCyan.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol.toUpperCase(),
                      style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (name.isNotEmpty)
                      Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
                      ),
                  ],
                ),
              ),
              if (price != null)
                Text(
                  AppFormatters.currency(price!),
                  style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
