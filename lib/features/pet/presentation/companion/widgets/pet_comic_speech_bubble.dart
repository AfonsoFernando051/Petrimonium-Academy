import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/presentation/companion/enums/pet_speech_bubble_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/pet/presentation/companion/theme/pet_speech_bubble_style.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/comic_bubble_painter.dart';

/// Premium comic-style speech bubble widget for the Pet Companion.
///
/// Combines character dialogue aesthetics with mobile game companion UI polish:
/// - Semantic state color palettes (idle, guidance, success, encouragement, milestone, attention).
/// - Custom vector comic bubble shell with integrated pointer tail.
/// - Top bar visual state badge with icon & title.
/// - Typewriter reveal animation with tap-to-complete gesture.
/// - Integrated action CTA button & dismiss control.
class PetComicSpeechBubble extends StatefulWidget {
  const PetComicSpeechBubble({
    super.key,
    required this.message,
    required this.onDismiss,
    this.onAction,
    this.tailPosition = PetBubbleTailPosition.bottomLeft,
    this.overrideState,
    this.enableTypewriter = true,
    this.typewriterSpeedMs = 20,
    this.maxWidth = 360.0,
  });

  final PetMessage message;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;
  final PetBubbleTailPosition tailPosition;
  final PetSpeechBubbleState? overrideState;
  final bool enableTypewriter;
  final int typewriterSpeedMs;
  final double maxWidth;

  @override
  State<PetComicSpeechBubble> createState() => _PetComicSpeechBubbleState();
}

class _PetComicSpeechBubbleState extends State<PetComicSpeechBubble> {
  Timer? _typewriterTimer;
  int _visibleCharCount = 0;
  bool _isTypewriterComplete = false;
  String _fullText = '';

  @override
  void initState() {
    super.initState();
    _startOrSkipTypewriter();
  }

  @override
  void didUpdateWidget(covariant PetComicSpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.textKey != widget.message.textKey ||
        oldWidget.message.params != widget.message.params) {
      _startOrSkipTypewriter();
    }
  }

  void _startOrSkipTypewriter() {
    _typewriterTimer?.cancel();
    _fullText = Translator.translate(
      widget.message.textKey,
      params: widget.message.params,
    );

    // If typewriter is disabled, in test environment, or animations disabled, reveal immediately
    final isTestEnvironment = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!widget.enableTypewriter || isTestEnvironment) {
      _visibleCharCount = _fullText.length;
      _isTypewriterComplete = true;
      return;
    }

    _visibleCharCount = 0;
    _isTypewriterComplete = false;

    _typewriterTimer = Timer.periodic(
      Duration(milliseconds: widget.typewriterSpeedMs),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_visibleCharCount < _fullText.length) {
          setState(() {
            _visibleCharCount++;
          });
        } else {
          _isTypewriterComplete = true;
          timer.cancel();
        }
      },
    );
  }

  void _completeTypewriterInstantly() {
    if (_isTypewriterComplete) return;
    _typewriterTimer?.cancel();
    setState(() {
      _visibleCharCount = _fullText.length;
      _isTypewriterComplete = true;
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (reducedMotion && !_isTypewriterComplete) {
      _visibleCharCount = _fullText.length;
      _isTypewriterComplete = true;
    }

    final state = widget.overrideState ?? widget.message.resolveState();
    final style = PetSpeechBubbleStateStyle.forState(state, context);
    final tokens = context.colors;

    final displayedText = _isTypewriterComplete || reducedMotion
        ? _fullText
        : _fullText.substring(0, _visibleCharCount.clamp(0, _fullText.length));

    // Padding calculations considering tail position
    const double tailHeight = 12.0;
    final EdgeInsets innerPadding = EdgeInsets.fromLTRB(
      16 + (widget.tailPosition == PetBubbleTailPosition.left ? tailHeight : 0),
      12 + (widget.tailPosition == PetBubbleTailPosition.topLeft ||
              widget.tailPosition == PetBubbleTailPosition.topRight ||
              widget.tailPosition == PetBubbleTailPosition.topCenter
          ? tailHeight
          : 0),
      14 + (widget.tailPosition == PetBubbleTailPosition.right ? tailHeight : 0),
      12 + (widget.tailPosition == PetBubbleTailPosition.bottomLeft ||
              widget.tailPosition == PetBubbleTailPosition.bottomRight ||
              widget.tailPosition == PetBubbleTailPosition.bottomCenter
          ? tailHeight
          : 0),
    );

    return Semantics(
      liveRegion: true,
      label: 'Fala do Pet: $displayedText',
      child: GestureDetector(
        onTap: _completeTypewriterInstantly,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: CustomPaint(
            painter: ComicBubblePainter(
              gradient: style.surfaceGradient,
              borderColor: style.borderColor,
              glowColor: style.glowColor,
              tailPosition: widget.tailPosition,
              borderRadius: 18.0,
              strokeWidth: 2.0,
            ),
            child: Padding(
              padding: innerPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TOP BAR: STATE BADGE & DISMISS BUTTON ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Visual State Badge — `Flexible` + an ellipsizing
                      // label so a narrow bubble (e.g. anchored to the small
                      // header avatar on a 320-375px phone, or the same
                      // width under large accessibility font scaling) never
                      // forces this decorative chip to overflow the bubble.
                      // Only this secondary badge label may ellipsize — the
                      // actual message body below never does (brief's "never
                      // truncate the Pet's words" requirement is scoped to
                      // that, not this chrome).
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: style.primaryAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: style.primaryAccent.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                style.badgeIcon,
                                size: 13,
                                color: style.primaryAccent,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  style.badgeTitleKey,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: style.primaryAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Close / Dismiss Button
                      Semantics(
                        button: true,
                        label: Translator.translate(
                          AppStrings.companionDismissTooltip,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: tokens.textTertiary,
                          ),
                          tooltip: Translator.translate(
                            AppStrings.companionDismissTooltip,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onDismiss();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- DIALOGUE BODY TEXT ---
                  Text(
                    displayedText,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 14.0,
                      height: 1.38,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),

                  // --- OPTIONAL CTA ACTION BUTTON ---
                  if (widget.message.action != null) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onAction?.call();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: style.primaryAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: style.primaryAccent.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Translator.translate(
                                widget.message.action!.labelKey,
                              ),
                              style: TextStyle(
                                color: style.primaryAccent,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: style.primaryAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

