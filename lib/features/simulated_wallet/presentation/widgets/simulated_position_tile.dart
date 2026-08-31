import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_position.dart';

class SimulatedPositionTile extends StatelessWidget {
  const SimulatedPositionTile({super.key, required this.position});

  final SimulatedPosition position;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.ticker,
                  style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary),
                ),
                Text(
                  '${position.quantity.toStringAsFixed(position.quantity.truncateToDouble() == position.quantity ? 0 : 6)} '
                  '@ R\$ ${position.averagePrice.toStringAsFixed(2)}',
                  style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${position.costBasis.toStringAsFixed(2)}',
                style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary),
              ),
              Text(
                '${position.allocationPercent.toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
