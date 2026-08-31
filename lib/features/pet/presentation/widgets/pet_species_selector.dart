import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';

/// `PetConfigurationScreen`'s horizontal species picker.
class PetSpeciesSelector extends StatefulWidget {
  const PetSpeciesSelector({super.key, required this.selected, required this.onSelected});

  final PetSpecieEnum selected;
  final ValueChanged<PetSpecieEnum> onSelected;

  @override
  State<PetSpeciesSelector> createState() => _PetSpeciesSelectorState();
}

class _PetSpeciesSelectorState extends State<PetSpeciesSelector> {
  // Explicit and shared with the Scrollbar below: without it, Scrollbar
  // can't reliably resolve which Scrollable to attach to inside this
  // screen's own nested (vertical) SingleChildScrollView, and throws.
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A visible thumb, not just scrollability: with 7 species the row
    // regularly overflows narrower layouts (the onboarding card included)
    // with no partial next-item peeking into view, so without this a
    // species past whatever fits the current width is undiscoverable —
    // nothing on screen hints there's more to scroll to.
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: PetSpecieEnum.values.length,
          itemBuilder: (context, index) {
            final specie = PetSpecieEnum.values[index];
            final isSelected = widget.selected == specie;
            final tokens = context.colors;
            return GestureDetector(
              onTap: () => widget.onSelected(specie),
              child: Container(
                width: 70,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : tokens.textPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: isSelected ? AppColors.neonCyan : tokens.textPrimary.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: AssetImage(PetAssets.imageFor(specie.name)), fit: BoxFit.cover),
                        border: Border.all(color: tokens.border, width: 1),
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
          },
        ),
      ),
    );
  }
}
