import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// One row in the "assets added so far" list — shows the ticker, quantity/
/// price and lets the user edit (reload into the form) or remove it before
/// confirming. Used inside a `ReorderableListView`, so it exposes a drag
/// handle rather than wrapping itself in one.
class AddedAssetTile extends StatelessWidget {
  const AddedAssetTile({
    super.key,
    required this.index,
    required this.asset,
    required this.onEdit,
    required this.onRemove,
  });

  final int index;
  final AssetRegistrationModel asset;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final type = asset.type;
    final isWholeUnits = asset.quantity.truncateToDouble() == asset.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: type.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.drag_indicator, color: context.colors.textTertiary, size: 18),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: type.color.withValues(alpha: 0.15),
              border: Border.all(color: type.color.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Icon(type.icon, color: type.color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name.toUpperCase(),
                  style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${isWholeUnits ? asset.quantity.toInt() : asset.quantity} un · ${AppFormatters.currency(asset.purchasePrice)}',
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.neonCyan, size: 18),
            tooltip: 'Editar',
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colors.error, size: 18),
            tooltip: 'Remover',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
