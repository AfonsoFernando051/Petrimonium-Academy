import 'package:flutter/widgets.dart';

/// A shareable handle pointing at "where the Pet visually renders" on a
/// screen, so [PetSpeechBubbleOverlay] can glue its bubble to the Pet's
/// actual on-screen position instead of a hardcoded screen coordinate (the
/// product spec's core complaint about the previous fixed-`Positioned`
/// overlay: the bubble and the Pet could end up nowhere near each other).
///
/// [link] is shared between a `CompositedTransformTarget` wrapping the Pet
/// visual (e.g. `PetCompanionHeader`'s avatar, `LearningHeroCard`'s big pet
/// art) and the `CompositedTransformFollower` the bubble renders through.
/// This is what keeps the bubble glued to the Pet even while it scrolls —
/// the compositor recomputes the follower's on-screen offset every frame
/// from the target's actual layer transform, with no manual scroll listener
/// needed.
///
/// [boxKey] additionally exposes the target's measured size/global position
/// (read once per shown message, not per frame) so the overlay can decide
/// which side of the Pet to place the bubble on and how wide it can safely
/// be without leaving the viewport.
///
/// One instance is created per screen-level Pet visual (owned by the host
/// screen, mirroring how `PetCompanionController` itself is owned) and
/// threaded down to both the visual widget and `PetSpeechBubbleOverlay`.
class PetSpeechBubbleAnchor {
  PetSpeechBubbleAnchor() : link = LayerLink(), boxKey = GlobalKey();

  final LayerLink link;
  final GlobalKey boxKey;
}
