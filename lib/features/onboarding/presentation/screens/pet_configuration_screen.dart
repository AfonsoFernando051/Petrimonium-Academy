import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/academy_intro_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/pet_hero_capsule.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/presentation/widgets/pet_name_field.dart';
import 'package:petrimonium/features/pet/presentation/widgets/pet_preview_panel.dart';
import 'package:petrimonium/features/pet/presentation/widgets/pet_species_selector.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Onboarding's "Configure Your Pet" step — the pet introduces itself, and
/// the player picks its species and name together in one screen right after
/// the emotional Welcome opener. The financial goal (`FinancialGoalScreen`)
/// and the Academy/Gamification narrative screens come after this one.
class PetConfigurationScreen extends StatefulWidget {
  const PetConfigurationScreen({super.key});

  @override
  State<PetConfigurationScreen> createState() => _PetConfigurationScreenState();
}

class _PetConfigurationScreenState extends State<PetConfigurationScreen> {
  static const _nameSuggestions = [
    'Atlas',
    'Bolt',
    'Loki',
    'Charlie',
    'Max',
    'Nino',
  ];

  PetSpecieEnum _selectedSpecie = PetSpecieEnum.DOG;
  bool _isLoading = false;
  bool _showNameError = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _pickSuggestion(String name) {
    HapticFeedback.selectionClick();
    setState(() {
      _nameController.text = name;
      _showNameError = false;
    });
  }

  Future<void> _handleContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.petRepository.configurePet(_selectedSpecie);
      await DI.mascotRepository.saveName(name);
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AcademyIntroScreen()));
      }
    } catch (e) {
      if (mounted) {
        GameSnack.show(
          context,
          '${Translator.translate(AppStrings.failedToSavePet)}: ${friendlyErrorMessage(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      intensity: BackgroundIntensity.subtle,
      step: 2,
      totalSteps: 7,
      maxContentWidth: 900,
      title: Translator.translate(AppStrings.meetPetTitle),
      subtitle: Translator.translate(AppStrings.meetPetIntro),
      ctaLabel: Translator.translate(AppStrings.meetPetContinue),
      isCtaLoading: _isLoading,
      onCta: _handleContinue,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _buildLeftPanel()),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(flex: 4, child: PetPreviewPanel()),
                  ],
                ),
              );
            }
            return Column(
              children: [
                _buildLeftPanel(),
                const SizedBox(height: AppSpacing.md),
                const PetPreviewPanel(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Translator.translate(AppStrings.meetPetNeedName),
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.goldenBorder, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: PetHeroCapsule(
              size: 210,
              child: Image.asset(
                PetAssets.imageFor(_selectedSpecie.name),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            Translator.translate(AppStrings.meetPetSpeciesPrompt),
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          PetSpeciesSelector(
            selected: _selectedSpecie,
            onSelected: (specie) => setState(() => _selectedSpecie = specie),
          ),
          const SizedBox(height: AppSpacing.xl),
          PetNameField(
            controller: _nameController,
            showError: _showNameError,
            suggestions: _nameSuggestions,
            onChanged: (_) {
              if (_showNameError) setState(() => _showNameError = false);
            },
            onSuggestionSelected: _pickSuggestion,
          ),
        ],
      ),
    );
  }
}
