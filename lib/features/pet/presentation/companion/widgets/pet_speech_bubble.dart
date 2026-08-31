import 'package:flutter/material.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/comic_bubble_painter.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_comic_speech_bubble.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';

/// Floats [PetCompanionController]'s current message next to wherever the
/// Pet actually renders on screen — anchored via [anchor], not a hardcoded
/// screen coordinate, so the bubble reads as the Pet's own speech instead of
/// an unrelated banner (`docs/investor_companion_speech_bubble_design_system
/// .md`'s "My companion is talking directly to me" test).
///
/// When [anchor] is provided, the bubble is glued to the anchor target
/// (typically `PetCompanionHeader`'s avatar or `LearningHeroCard`'s big pet
/// art) via `CompositedTransformFollower`. That tracks the target's actual
/// position live, including while it scrolls (e.g. Home's
/// `SingleChildScrollView`), with no manual scroll-offset bookkeeping — the
/// compositor recomputes the offset every frame from the target's layer
/// transform. Which side of the anchor the bubble grows toward, whether it
/// sits above or below, and how wide it can safely be are all computed once
/// per shown message from the anchor's *measured* screen position, so the
/// same widget adapts to every host screen instead of needing per-screen
/// tuning.
///
/// When [anchor] is omitted (the showcase screen, or any host that hasn't
/// registered a Pet visual), falls back to a plain top-center placement.
///
/// Rendered through an [OverlayEntry] rather than inline in the host's
/// widget tree. `CompositedTransformFollower` requires its target to have
/// *painted* earlier in the same frame — a plain requirement that broke for
/// [anchor]s living in an `AppBar` (e.g. `PetCompanionHeader`), since
/// `Scaffold` paints its `body` before its `appBar` so the bar's shadow sits
/// on top. Inserting into the app's root `Overlay` (already used by
/// `Navigator` for routes/dialogs) guarantees this widget paints last —
/// after every possible anchor location — regardless of which screen region
/// hosts the Pet.
class PetSpeechBubbleOverlay extends StatefulWidget {
  const PetSpeechBubbleOverlay({
    super.key,
    required this.controller,
    this.anchor,
    this.onActionSelected,
  });

  final PetCompanionController controller;

  /// Where the Pet actually renders on this screen. See
  /// [PetSpeechBubbleAnchor]'s doc comment.
  final PetSpeechBubbleAnchor? anchor;

  /// Invoked with the tapped action's destination context when the message
  /// has one — the host screen owns navigation (tab switches, pushes), this
  /// widget only reports the intent.
  final ValueChanged<PetMessageAction>? onActionSelected;

  @override
  State<PetSpeechBubbleOverlay> createState() => _PetSpeechBubbleOverlayState();
}

class _PetSpeechBubbleOverlayState extends State<PetSpeechBubbleOverlay> {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final entry = OverlayEntry(builder: _buildOverlayContent);
      _entry = entry;
      Overlay.of(context).insert(entry);
    });
  }

  @override
  void didUpdateWidget(covariant PetSpeechBubbleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The bubble's own content listens to `controller` directly, so only
    // prop changes the OverlayEntry's builder closure wouldn't otherwise
    // pick up on its own (e.g. `anchor` swapping when the host switches
    // tabs) need an explicit rebuild request.
    if (oldWidget.controller != widget.controller ||
        oldWidget.anchor != widget.anchor ||
        oldWidget.onActionSelected != widget.onActionSelected) {
      // `OverlayEntry.markNeedsBuild` calls `setState` on the overlay's own
      // element — calling it synchronously here would happen *during* this
      // widget's own ancestor's build phase (that's what triggered
      // `didUpdateWidget`), which throws. Deferring to the next frame is
      // safe and invisible to the user (well under a frame's delay).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _entry?.markNeedsBuild();
      });
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    // A transparent `Material` ancestor: this content is inserted into the
    // app's root `Overlay` (see class doc), which sits outside any
    // screen's own `Scaffold`/`Material` — without this, `PetComicSpeechBubble`'s
    // CTA `InkWell` has nothing to paint its ink response onto.
    return Material(
      type: MaterialType.transparency,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final message = widget.controller.currentMessage;
          return AnimatedSwitcher(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            ),
            child: message == null
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : _AnchoredBubble(
                    key: ValueKey(message.id),
                    message: message,
                    controller: widget.controller,
                    anchor: widget.anchor,
                    onActionSelected: widget.onActionSelected,
                  ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _AnchoredBubble extends StatelessWidget {
  const _AnchoredBubble({
    super.key,
    required this.message,
    required this.controller,
    required this.anchor,
    required this.onActionSelected,
  });

  final PetMessage message;
  final PetCompanionController controller;
  final PetSpeechBubbleAnchor? anchor;
  final ValueChanged<PetMessageAction>? onActionSelected;

  Widget _bubble(PetBubbleTailPosition tail, double maxWidth) =>
      PetComicSpeechBubble(
        message: message,
        tailPosition: tail,
        maxWidth: maxWidth,
        onDismiss: controller.dismiss,
        onAction: () {
          if (message.action != null) {
            controller.dismiss();
            onActionSelected?.call(message.action!);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final resolvedAnchor = anchor;
    if (resolvedAnchor == null) {
      return Align(
        alignment: Alignment.topCenter,
        child: _bubble(PetBubbleTailPosition.bottomLeft, 360),
      );
    }

    final placement = PetBubblePlacement.resolve(
      context,
      resolvedAnchor.boxKey,
    );
    return CompositedTransformFollower(
      link: resolvedAnchor.link,
      showWhenUnlinked: false,
      targetAnchor: placement.targetAnchor,
      followerAnchor: placement.followerAnchor,
      offset: placement.offset,
      child: _bubble(placement.tail, placement.maxWidth),
    );
  }
}

enum _PetAnchorSide { left, center, right }

/// Where, relative to a measured Pet anchor, the speech bubble should sit —
/// which side it grows toward, whether it's above or below, and how wide it
/// can safely be before it risks leaving the viewport. Computed fresh each
/// time a message is shown (not on every frame — live tracking of the
/// anchor's actual pixel offset, including through scrolling, is handled by
/// `CompositedTransformFollower` itself).
class PetBubblePlacement {
  const PetBubblePlacement({
    required this.tail,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
    required this.maxWidth,
  });

  final PetBubbleTailPosition tail;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;
  final double maxWidth;

  static const double _gap = 10.0;
  static const double _horizontalMargin = 16.0;
  static const double _defaultMaxWidth = 320.0;
  static const double _minMaxWidth = 220.0;

  /// Below this much room above the anchor, there isn't enough space for a
  /// comfortably-sized bubble to sit above it (e.g. the header avatar,
  /// which lives inside the AppBar itself) — so the bubble is placed below
  /// the anchor instead, with an upward-pointing tail.
  static const double _minSpaceAboveForTopPlacement = 140.0;

  static PetBubblePlacement resolve(BuildContext context, GlobalKey anchorKey) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final renderObject = anchorKey.currentContext?.findRenderObject();

    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      // The anchor hasn't laid out yet (should be rare — Pet visuals mount
      // well before any event-driven message can fire). Fall back to a
      // reasonable default rather than crashing.
      return const PetBubblePlacement(
        tail: PetBubbleTailPosition.bottomCenter,
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        offset: Offset(0, -_gap),
        maxWidth: _defaultMaxWidth,
      );
    }

    final anchorTopLeft = renderObject.localToGlobal(Offset.zero);
    final anchorSize = renderObject.size;
    final anchorCenterX = anchorTopLeft.dx + anchorSize.width / 2;
    final placeBelow = anchorTopLeft.dy < _minSpaceAboveForTopPlacement;

    final horizontalFraction = screenWidth <= 0
        ? 0.5
        : anchorCenterX / screenWidth;
    final side = horizontalFraction < 0.4
        ? _PetAnchorSide.left
        : (horizontalFraction > 0.6
              ? _PetAnchorSide.right
              : _PetAnchorSide.center);

    final maxWidthRaw = switch (side) {
      _PetAnchorSide.left => screenWidth - anchorTopLeft.dx - _horizontalMargin,
      _PetAnchorSide.right =>
        anchorTopLeft.dx + anchorSize.width - _horizontalMargin,
      _PetAnchorSide.center => screenWidth - _horizontalMargin * 2,
    };

    return PetBubblePlacement(
      tail: _tailFor(side, placeBelow),
      targetAnchor: _targetAnchorFor(side, placeBelow),
      followerAnchor: _followerAnchorFor(side, placeBelow),
      offset: Offset(0, placeBelow ? _gap : -_gap),
      maxWidth: maxWidthRaw.clamp(_minMaxWidth, _defaultMaxWidth),
    );
  }

  static Alignment _targetAnchorFor(_PetAnchorSide side, bool below) =>
      switch (side) {
        _PetAnchorSide.left => below ? Alignment.bottomLeft : Alignment.topLeft,
        _PetAnchorSide.right =>
          below ? Alignment.bottomRight : Alignment.topRight,
        _PetAnchorSide.center =>
          below ? Alignment.bottomCenter : Alignment.topCenter,
      };

  static Alignment _followerAnchorFor(_PetAnchorSide side, bool below) =>
      switch (side) {
        _PetAnchorSide.left => below ? Alignment.topLeft : Alignment.bottomLeft,
        _PetAnchorSide.right =>
          below ? Alignment.topRight : Alignment.bottomRight,
        _PetAnchorSide.center =>
          below ? Alignment.topCenter : Alignment.bottomCenter,
      };

  static PetBubbleTailPosition _tailFor(_PetAnchorSide side, bool below) =>
      switch ((side, below)) {
        (_PetAnchorSide.left, false) => PetBubbleTailPosition.bottomLeft,
        (_PetAnchorSide.left, true) => PetBubbleTailPosition.topLeft,
        (_PetAnchorSide.right, false) => PetBubbleTailPosition.bottomRight,
        (_PetAnchorSide.right, true) => PetBubbleTailPosition.topRight,
        (_PetAnchorSide.center, false) => PetBubbleTailPosition.bottomCenter,
        (_PetAnchorSide.center, true) => PetBubbleTailPosition.topCenter,
      };
}
