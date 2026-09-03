import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';

/// The animated pet + speech bubble that reacts to portfolio-setup
/// progress — the emotional guide through onboarding, per the brief. Reuses
/// the same `generated_{specie}.png` assets and breathing/floating
/// animation style as `PetShowcase` for visual continuity with the rest of
/// the app, rather than introducing a new mascot rendering approach.
class PetCompanionCard extends StatefulWidget {
  const PetCompanionCard({super.key, required this.assetCount});

  final int assetCount;

  @override
  State<PetCompanionCard> createState() => _PetCompanionCardState();
}

class _PetCompanionCardState extends State<PetCompanionCard> with TickerProviderStateMixin {
  String _petAsset = 'assets/images/fox_compass.png';

  late final AnimationController _breatheController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _breatheAnimation =
      Tween<double>(begin: 0.97, end: 1.03).animate(CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut));
  bool _breatheLoopStarted = false;

  late final AnimationController _bounceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _bounceAnimation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -24.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 45),
    TweenSequenceItem(tween: Tween(begin: -24.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 55),
  ]).animate(_bounceController);

  @override
  void initState() {
    super.initState();
    _fetchSpecie();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _breatheController.value = 0.5;
      _breatheLoopStarted = false;
    } else if (!_breatheLoopStarted) {
      _breatheController.repeat(reverse: true);
      _breatheLoopStarted = true;
    }
  }

  Future<void> _fetchSpecie() async {
    try {
      final petData = await DI.petRepository.getMyPet();
      final specie = petData?['specie']?.toString();
      if (specie != null && mounted) {
        setState(() => _petAsset = PetAssets.imageFor(specie));
      }
    } catch (_) {
      // Keep the fallback compass-fox illustration.
    }
  }

  @override
  void didUpdateWidget(covariant PetCompanionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assetCount != oldWidget.assetCount) {
      HapticFeedback.mediumImpact();
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  ({String mood, String message}) get _reaction {
    final count = widget.assetCount;
    if (count == 0) {
      return (
        mood: '🙂',
        message: 'Todo grande investidor começa com um único investimento. Vamos começar?',
      );
    }
    if (count == 1) {
      return (
        mood: '😄',
        message: 'Parabéns! Você começou sua jornada de investimentos!',
      );
    }
    if (count == 2) {
      return (mood: '🎉', message: 'Seu portfólio está crescendo!');
    }
    if (count < 5) {
      return (mood: '🚀', message: 'Ótimo trabalho! Nova missão desbloqueada!');
    }
    return (mood: '🏆', message: 'Você está pronto para o seu primeiro desafio!');
  }

  @override
  Widget build(BuildContext context) {
    final reaction = _reaction;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpeechBubble(mood: reaction.mood, message: reaction.message),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: Listenable.merge([_breatheController, _bounceController]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Transform.scale(scale: _breatheAnimation.value, child: child),
            );
          },
          child: Image.asset(
            _petAsset,
            height: 220,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Image.asset('assets/images/fox_compass.png', height: 220),
          ),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.mood, required this.message});

  final String mood;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(message),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
