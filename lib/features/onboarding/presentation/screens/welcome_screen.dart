import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/pet_hero_capsule.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/pet_configuration_screen.dart';

/// Onboarding's opening beat — a real emotional entrance rather than a form.
/// No species/name is chosen yet (that's `PetConfigurationScreen`, the next
/// screen), so the pet is shown generically via `PetAssets.imageFor(null)`
/// (safe default portrait) as "the adventure about to begin", not as the
/// player's actual companion yet.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goNext(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PetConfigurationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      intensity: BackgroundIntensity.balanced,
      step: 1,
      totalSteps: 7,
      showSkip: true,
      onSkip: () => _goNext(context),
      title: Translator.translate(AppStrings.welcomeHeadline),
      subtitle: Translator.translate(AppStrings.welcomeBody),
      ctaLabel: Translator.translate(AppStrings.welcomeCta),
      onCta: () => _goNext(context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.brandGradient),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              Translator.translate(AppStrings.welcomeSubheadline),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const _FloatingIcon(
                  icon: Icons.paid_outlined,
                  color: AppColors.goldenBorder,
                  alignment: Alignment(-0.95, -0.65),
                  delayMs: 0,
                ),
                const _FloatingIcon(
                  icon: Icons.show_chart,
                  color: AppColors.neonCyan,
                  alignment: Alignment(0.95, -0.55),
                  delayMs: 400,
                ),
                const _FloatingIcon(
                  icon: Icons.menu_book_outlined,
                  color: AppColors.neonPink,
                  alignment: Alignment(-0.9, 0.75),
                  delayMs: 800,
                ),
                const _FloatingIcon(
                  icon: Icons.star_rounded,
                  color: AppColors.neonPurple,
                  alignment: Alignment(0.9, 0.7),
                  delayMs: 1200,
                ),
                PetHeroCapsule(
                  size: 230,
                  child: Image.asset(
                    PetAssets.imageFor(null),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.alignment,
    required this.delayMs,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;
  final int delayMs;

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _float = Tween<double>(
    begin: -6.0,
    end: 6.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            Transform.translate(offset: Offset(0, _float.value), child: child),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.14),
            border: Border.all(color: widget.color.withValues(alpha: 0.35)),
          ),
          child: Icon(
            widget.icon,
            color: widget.color.withValues(alpha: 0.85),
            size: 18,
          ),
        ),
      ),
    );
  }
}
