import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/game/domain/entities/player_level.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/game/domain/services/level_title.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_evolution_rule.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';

/// Home's "where am I, and how is my companion doing" hero
/// (`docs/PRODUCT_VISION.md` §8 #2 and #3): level + XP progress toward the
/// next level, and the pet with XP progress toward its next evolution.
///
/// Redesigned from the former `dashboard/presentation/widgets/pet_showcase
/// .dart`: the aura no longer derives from portfolio performance, and the
/// backend-`health`-driven "HP" bar (a decorative field, never actually
/// updated — see `PetApp-Backend`'s `ConfigurePetUseCaseImpl`) is replaced
/// by a real XP-to-next-evolution bar. The pet represents learning
/// progression, never investment volume or performance
/// (`docs/PRODUCT_VISION.md` §9, §11).
class LearningHeroCard extends StatefulWidget {
  const LearningHeroCard({super.key, required this.mascotController, this.anchor});

  final MascotController mascotController;

  /// When provided, registers this card's pet art as the Pet's on-screen
  /// position for `PetSpeechBubbleOverlay` to glue its bubble to — see
  /// [PetSpeechBubbleAnchor]. Home's big, animated pet is the more
  /// expressive of the app's two Pet visuals, so it takes priority over the
  /// header avatar whenever this card is the visible tab.
  final PetSpeechBubbleAnchor? anchor;

  @override
  State<LearningHeroCard> createState() => _LearningHeroCardState();
}

class _LearningHeroCardState extends State<LearningHeroCard> with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _bounceController;
  late AnimationController _celebrationController;

  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _celebrationAnimation;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<AppEvent>? _celebrationEventSubscription;
  final ValueNotifier<Offset> _parallax = ValueNotifier(Offset.zero);
  bool _ambientLoopsStarted = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAccelerometer();
    _initCelebrationListener();
  }

  void _initAnimations() {
    // Ambient loops (breathe/float/glow) are created here but only started
    // in didChangeDependencies, once MediaQuery is reliably available to
    // check disableAnimations — see that override.
    _breatheController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _breatheAnimation = Tween<double>(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine));

    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _floatAnimation =
        Tween<double>(begin: -6.0, end: 8.0).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    // Deliberately subtle and slow: this ambient aura sits behind the
    // Level-2 companion, one card below Home's primary CTA
    // (`NextActionCard`) — it should read as calm presence, not
    // compete for attention (`docs/DESIGN_SYSTEM.md`'s "avoid unnecessary
    // visual complexity" / brief's "reduce competing highlights"). Kept
    // deliberately lower-amplitude than the card above it — see
    // `_celebrationController` for the one moment this aura is allowed to
    // get louder than ambient.
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _glowAnimation =
        Tween<double>(begin: 0.05, end: 0.14).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _bounceAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -30).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: -30, end: 0).chain(CurveTween(curve: Curves.bounceOut)), weight: 50),
    ]).animate(_bounceController);

    // One-shot, not looping: fires only on a real level-up/evolution (see
    // _initCelebrationListener), so "expressive" and "ambient" are
    // genuinely different pet states rather than the same loop throughout.
    _celebrationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _celebrationAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeIn)), weight: 80),
    ]).animate(_celebrationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _breatheController.value = 0.5;
      _floatController.value = 0.5;
      _glowController.value = 0.5;
      _ambientLoopsStarted = false;
    } else if (!_ambientLoopsStarted) {
      _breatheController.repeat(reverse: true);
      _floatController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
      _ambientLoopsStarted = true;
    }
  }

  /// A real level-up or pet evolution — never a portfolio/wealth event, see
  /// class doc — is the one moment this ambient card is allowed to be
  /// louder than its resting state, via [_celebrationController].
  void _initCelebrationListener() {
    _celebrationEventSubscription = AppEventBus.instance.stream.listen((event) {
      if (event is PetEvolvedEvent || event is UserLeveledUpEvent) {
        _triggerCelebration();
      }
    });
  }

  void _triggerCelebration() {
    if (!mounted) return;
    if (MediaQuery.of(context).disableAnimations) return;
    HapticFeedback.mediumImpact();
    _celebrationController.forward(from: 0.0);
  }

  // `sensors_plus` only ships a real platform implementation for
  // Android/iOS (and a DeviceMotion-backed one for web); on desktop
  // (Linux/Windows/macOS) there is no receiver registered at all. Its
  // method-channel layer fires `invokeMethod('setAccelerationSamplingPeriod',
  // ...)` internally without awaiting it, so the resulting
  // `MissingPluginException` surfaces as an *unhandled* async error no
  // surrounding try/catch can intercept — the only reliable fix is to never
  // call `accelerometerEventStream()` on a platform that can't answer it.
  bool get _accelerometerSupported =>
      kIsWeb || Platform.isAndroid || Platform.isIOS;

  void _initAccelerometer() {
    if (!_accelerometerSupported) return;
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (event) {
          _parallax.value = Offset(
            (event.x * -3.0).clamp(-20.0, 20.0),
            (event.y * 3.0).clamp(-20.0, 20.0),
          );
        },
        onError: (Object error) {
          debugPrint('Accelerometer not available: $error');
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Accelerometer not available: $e');
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _celebrationEventSubscription?.cancel();
    _breatheController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    _celebrationController.dispose();
    _parallax.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    if (!_bounceController.isAnimating) {
      HapticFeedback.lightImpact();
      _bounceController.forward(from: 0.0);
    }
  }

  /// Aura color reflects the pet's evolution tier, never portfolio
  /// performance — see class doc.
  Color _auraColorFor(int tier) {
    if (tier >= 7) return AppColors.goldenBorder;
    if (tier >= 4) return AppColors.neonViolet;
    return AppColors.neonCyan;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCardAndPet(),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildCardAndPet() {
    final profile = widget.mascotController.profile;
    final level = LevelCalculator.fromXp(profile.xp);
    final auraColor = _auraColorFor(profile.stage.tier);

    final nextRule = PetEvolutionRule.defaultRules.firstWhere(
      (r) => r.stage.tier > profile.stage.tier,
      orElse: () => PetEvolutionRule.defaultRules.last,
    );
    final hasNextEvolution = nextRule.stage != profile.stage;
    final evolutionProgress = hasNextEvolution && nextRule.minXp > 0 ? (profile.xp / nextRule.minXp).clamp(0.0, 1.0) : 1.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        GlassCard(
          backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
          borderColor: auraColor.withValues(alpha: 0.3),
          borderWidth: 1,
          borderRadius: 24,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 18),
            child: Column(
              children: [
                _buildLevelHeader(context, level),
                const SizedBox(height: 20),
                _buildBackdrop(auraColor),
                const SizedBox(height: 12),
                _buildEvolutionBar(context, hasNextEvolution: hasNextEvolution, progress: evolutionProgress, nextRule: nextRule, profileXp: profile.xp, auraColor: auraColor),
              ],
            ),
          ),
        ),
        // Anchored to the arch's bottom edge, not the card's: the card now
        // has _buildEvolutionBar (plus its spacing and the card's bottom
        // padding) below the arch, so a bottom offset measured from the
        // card edge — as before this section existed — leaves the pet and
        // its pedestal floating in that extra space instead of sitting on
        // the arch.
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: _triggerBounce,
            child: _wrapWithAnchor(SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: 32,
                    child: Container(
                      width: 260,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.spaceDark,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: auraColor.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
                        border: Border.all(color: auraColor.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 47,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _breatheController,
                        _floatController,
                        _bounceController,
                        _celebrationController,
                        _parallax,
                      ]),
                      builder: (context, child) {
                        // A real level-up/evolution adds a brief extra scale
                        // bump on top of the ambient breathe — see
                        // _initCelebrationListener.
                        final celebrationScale = 1.0 + (_celebrationAnimation.value * 0.12);
                        return Transform.translate(
                          offset: Offset(
                            _parallax.value.dx,
                            _parallax.value.dy + _floatAnimation.value + _bounceAnimation.value,
                          ),
                          child: Transform.scale(
                            scaleY: _breatheAnimation.value * celebrationScale,
                            scaleX: (1.0 + (1.0 - _breatheAnimation.value)) * celebrationScale,
                            child: Image.asset(
                              PetAssets.imageFor(widget.mascotController.profile.specie.name),
                              height: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(Icons.pets, size: 100, color: Colors.white70),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _wrapWithAnchor(Widget child) {
    final anchor = widget.anchor;
    if (anchor == null) return child;
    return CompositedTransformTarget(
      link: anchor.link,
      child: KeyedSubtree(key: anchor.boxKey, child: child),
    );
  }

  Widget _buildLevelHeader(BuildContext context, PlayerLevel level) {
    final tokens = context.colors;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Center(
            child: Text(
              '${level.level}',
              style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LevelTitle.forLevel(level.level),
                style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              _thinProgressBar(context, progress: level.progress, color: AppColors.neonCyan),
              const SizedBox(height: 3),
              Text(
                '${Translator.translate(AppStrings.homeLevelProgressLabel)} · ${level.xpIntoLevel}/${level.xpForNextLevel} XP',
                style: TextStyle(color: tokens.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvolutionBar(
    BuildContext context, {
    required bool hasNextEvolution,
    required double progress,
    required PetEvolutionRule nextRule,
    required int profileXp,
    required Color auraColor,
  }) {
    final tokens = context.colors;
    return Column(
      children: [
        _thinProgressBar(context, progress: progress, color: auraColor),
        const SizedBox(height: 4),
        Text(
          hasNextEvolution
              ? '${Translator.translate(AppStrings.homeNextEvolutionLabel)} · $profileXp/${nextRule.minXp} XP'
              : Translator.translate(AppStrings.homeMaxEvolutionLabel),
          style: TextStyle(color: tokens.textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _thinProgressBar(BuildContext context, {required double progress, required Color color}) {
    final tokens = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(height: 6, width: double.infinity, color: tokens.textTertiary.withValues(alpha: 0.18)),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: 6,
              decoration: BoxDecoration(color: color, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop(Color auraColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.spaceDark.withValues(alpha: 0.85), AppColors.spaceDark.withValues(alpha: 0)],
              stops: const [0.35, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([_glowController, _celebrationController]),
          builder: (context, child) {
            // Ambient ceiling is deliberately low (see _glowAnimation's tween
            // range) so this card never out-competes NextActionCard
            // above it — the one moment it's allowed to bloom brighter is a
            // real celebration burst, not continuous ambience.
            final glow = (_glowAnimation.value + _celebrationAnimation.value * 0.4).clamp(0.0, 0.55);
            return Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: auraColor.withValues(alpha: glow),
                    blurRadius: 24 + (glow * 40),
                    spreadRadius: 4 + (_celebrationAnimation.value * 6),
                  ),
                ],
              ),
            );
          },
        ),
        Container(
          width: 240,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(120), bottom: Radius.circular(30)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent, auraColor.withValues(alpha: 0.14)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
        ),
      ],
    );
  }
}
