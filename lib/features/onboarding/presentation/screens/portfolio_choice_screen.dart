import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';

/// Onboarding's final, deliberately non-blocking step. It makes clear that
/// learning can come before investing and that a portfolio is useful later,
/// once the user has investments for the mentor to analyze.
class PortfolioChoiceScreen extends StatefulWidget {
  const PortfolioChoiceScreen({super.key});

  @override
  State<PortfolioChoiceScreen> createState() => _PortfolioChoiceScreenState();
}

class _PortfolioChoiceScreenState extends State<PortfolioChoiceScreen> {
  String? _petName;

  @override
  void initState() {
    super.initState();
    _loadPetName();
  }

  Future<void> _loadPetName() async {
    final profile = await DI.mascotRepository.loadProfile();
    if (mounted) setState(() => _petName = profile.name);
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _startLearning() async {
    await DI.onboardingStateRepository.markPortfolioSkipped();
    if (mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        intensity: BackgroundIntensity.subtle,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderColor: AppColors.neonCyan.withValues(alpha: 0.4),
                  borderRadius: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        color: AppColors.neonCyan.withValues(alpha: 0.85),
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Translator.translate(AppStrings.portfolioChoiceTitle),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        Translator.translate(AppStrings.portfolioChoiceBody),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _GuidanceItem(
                        icon: Icons.school_outlined,
                        title: AppStrings.portfolioGuidanceLearnTitle,
                        body: AppStrings.portfolioGuidanceLearnBody,
                      ),
                      const SizedBox(height: 12),
                      _GuidanceItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: AppStrings.portfolioGuidancePortfolioTitle,
                        body: AppStrings.portfolioGuidancePortfolioBody,
                      ),
                      const SizedBox(height: 12),
                      _GuidanceItem(
                        icon: Icons.auto_awesome_outlined,
                        title: AppStrings.portfolioGuidanceMentorTitle,
                        body: AppStrings.portfolioGuidanceMentorBody,
                      ),
                      const SizedBox(height: 24),
                      GameButton(
                        label: Translator.translate(
                          AppStrings.portfolioGuidanceContinueButton,
                        ),
                        icon: Icons.school_outlined,
                        colors: const [
                          AppColors.neonViolet,
                          AppColors.neonPink,
                        ],
                        onPressed: _startLearning,
                      ),
                      if (_petName != null && _petName!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          Translator.translate(
                            AppStrings.portfolioChoiceFootnote,
                            params: {'petName': _petName!},
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidanceItem extends StatelessWidget {
  const _GuidanceItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translator.translate(title),
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                Translator.translate(body),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
