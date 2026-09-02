import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';

/// `PetConfigurationScreen`'s species picker — a 2-column grid of cards
/// (portrait + label), matching the Notion mockup's "Escolha seu parceiro
/// de jornada" layout. Built from plain `Column`/`Row` rather than
/// `GridView` — `PetConfigurationScreen`'s wide-layout branch wraps this in
/// an `IntrinsicHeight`, which a sliver-based `GridView` can't answer
/// ("does not support returning intrinsic dimensions"); `Row`/`Column` do.
///
/// [PetSpecieEnum]'s 7 values mirror the backend's wire format 1:1 (see
/// that enum's own doc comment), so every one of them stays selectable
/// here even though the mockup's screenshot only shows 4 — this grid just
/// presents the same real catalog in the mockup's visual style, it doesn't
/// cut species the backend and existing pets still support.
class PetSpeciesSelector extends StatelessWidget {
  const PetSpeciesSelector({super.key, required this.selected, required this.onSelected});

  final PetSpecieEnum selected;
  final ValueChanged<PetSpecieEnum> onSelected;

  @override
  Widget build(BuildContext context) {
    final species = PetSpecieEnum.values;
    final rows = <Widget>[];
    for (var i = 0; i < species.length; i += 2) {
      final second = i + 1 < species.length ? species[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < species.length ? AppSpacing.md : 0),
          child: Row(
            children: [
              Expanded(
                child: _SpeciesCard(
                  specie: species[i],
                  isSelected: selected == species[i],
                  onTap: () => onSelected(species[i]),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: second == null
                    ? const SizedBox.shrink()
                    : _SpeciesCard(
                        specie: second,
                        isSelected: selected == second,
                        onTap: () => onSelected(second),
                      ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _SpeciesCard extends StatelessWidget {
  const _SpeciesCard({required this.specie, required this.isSelected, required this.onTap});

  final PetSpecieEnum specie;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.14) : tokens.textPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : tokens.textPrimary.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                PetAssets.imageFor(specie.name),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              specie.name[0].toUpperCase() + specie.name.substring(1).toLowerCase(),
              style: AppTextStyles.label.copyWith(
                color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
