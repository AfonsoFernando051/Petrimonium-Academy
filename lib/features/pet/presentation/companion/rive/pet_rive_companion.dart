import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/widgets/pet_mascot_widget.dart';

/// How a species' bundled `.riv` should be driven to reflect
/// [PetAnimationState]. Every bundled file is expected to satisfy the
/// default [_CompanionRig] — a single artboard exposing a `Companion` state
/// machine with a persistent `state` number input plus `reducedMotion`/
/// `interacting` bools (see `docs/RIVE_PET_COMPANION_BRIEF.md`) — except the
/// two stopgap reference assets bundled ahead of any real `Companion`-
/// contract file existing, which need their own adapter:
/// - `dog.riv` ([_TriggerRig]) is `pet_cachorro_state_machine.riv` verbatim:
///   one artboard, but poses are fired as one-shot triggers on a
///   differently-named state machine, not a persistent number input.
/// - `owl.riv` ([_PoseSwapRig]) is the owl mascot expression-pack reference
///   asset verbatim: no unified state machine at all — each pose is its own
///   self-contained, autoplaying artboard, so "switching pose" means
///   swapping which artboard is mounted rather than driving any input.
///   `RiveAnimation` already re-initializes when its `artboard` parameter
///   changes, so no manual key/remount plumbing is needed for this.
///
/// [_kRigForSpecie] is deliberately keyed only by the species that actually
/// have a bundled stopgap today; anything else falls through to
/// [_CompanionRig], which is what a real future asset is meant to satisfy.
sealed class _RiveCompanionRig {
  const _RiveCompanionRig(this.stateMachineName);

  final String stateMachineName;
}

class _CompanionRig extends _RiveCompanionRig {
  const _CompanionRig() : super('Companion');
}

class _TriggerRig extends _RiveCompanionRig {
  const _TriggerRig(super.stateMachineName, this.triggerForState);

  /// `null` means "no trigger — stay on/return to the rig's built-in idle
  /// pose".
  final String? Function(PetAnimationState) triggerForState;
}

class _PoseSwapRig extends _RiveCompanionRig {
  const _PoseSwapRig(super.stateMachineName, this.artboardForState);

  final String Function(PetAnimationState) artboardForState;
}

/// [PetAnimationState.sleep] has no real counterpart in `dog.riv`, so it
/// borrows `Blink` (eyes closing) as the closest available stand-in until a
/// proper sleep pose is authored.
String? _dogTriggerForState(PetAnimationState state) {
  switch (state) {
    case PetAnimationState.idle:
      return null;
    case PetAnimationState.happy:
      return 'Happy';
    case PetAnimationState.celebrate:
      return 'Tail Wag';
    case PetAnimationState.victory:
      return 'Excited';
    case PetAnimationState.think:
      return 'Sit';
    case PetAnimationState.sleep:
      return 'Blink';
  }
}

/// Owl expression-pack artboard names (see
/// `assets/rive/tests/25712-48015-owl-mascot-expression-pack-*.riv`) chosen
/// for each [PetAnimationState]. Like the dog stopgap, [PetAnimationState.sleep]
/// has no literal sleep pose in this pack — artboard `13` (calm, one eye
/// closed) is the closest available stand-in.
String _owlArtboardForState(PetAnimationState state) {
  switch (state) {
    case PetAnimationState.idle:
      return '1';
    case PetAnimationState.happy:
      return '5';
    case PetAnimationState.celebrate:
      return '10';
    case PetAnimationState.think:
      return '11';
    case PetAnimationState.sleep:
      return '13';
    case PetAnimationState.victory:
      return '14';
  }
}

const Map<String, _RiveCompanionRig> _kRigForSpecie = {
  'dog': _TriggerRig('Pet State Machine', _dogTriggerForState),
  'owl': _PoseSwapRig('State Machine 1', _owlArtboardForState),
};

_RiveCompanionRig _rigFor(String specieKey) => _kRigForSpecie[specieKey] ?? const _CompanionRig();

/// Drop-in replacement for [PetMascotWidget] that renders the pet companion
/// through its Rive character (`assets/rive/pet/{specie}.riv`) once one
/// exists, and falls back to [PetMascotWidget] until then.
///
/// `dog.riv` and `owl.riv` are bundled today (both stopgap reference assets,
/// verbatim — see [_kRigForSpecie]); every other species still renders the
/// fallback because nothing is bundled at that asset path yet (see
/// `assets/rive/pet/README.md`).
class PetRiveCompanion extends StatefulWidget {
  const PetRiveCompanion({
    super.key,
    required this.controller,
    this.size = 220,
    this.interactive = true,
    this.interacting = false,
  });

  final MascotController controller;
  final double size;
  final bool interactive;

  /// Whether the companion's interaction panel is currently open — mirrors
  /// the optional `interacting` state-machine input from the target
  /// `Companion` contract (`docs/RIVE_PET_COMPANION_BRIEF.md`). Only
  /// consumed by [_CompanionRig]; the `dog.riv`/`owl.riv` stopgap rigs have
  /// no such input, so it's accepted but unused for those two species.
  final bool interacting;

  @override
  State<PetRiveCompanion> createState() => _PetRiveCompanionState();
}

class _PetRiveCompanionState extends State<PetRiveCompanion> {
  // Asset paths that have already failed to load once — checked again on
  // every rebuild otherwise, since a StatefulWidget doesn't cache across
  // instances (header + interaction sheet each mount their own). Process-
  // lifetime only; there's no cache-invalidation need since app assets don't
  // change without a fresh install.
  static final Set<String> _knownMissing = {};

  RiveFile? _riveFile;
  _RiveCompanionRig _rig = const _CompanionRig();
  StateMachineController? _smController;

  // _CompanionRig inputs.
  SMINumber? _stateInput;
  SMIBool? _reducedMotionInput;
  SMIBool? _interactingInput;

  // _TriggerRig state.
  final Map<PetAnimationState, SMITrigger> _triggers = {};

  /// The animation state last synced to a [_TriggerRig], so state *changes*
  /// — not every rebuild — fire a trigger. Triggers are edge events in Rive
  /// (unlike [_CompanionRig]'s persistent `state` number input), so firing
  /// on every rebuild would spam the rig with redundant pulses.
  PetAnimationState? _lastSyncedState;

  String get _specieKey {
    final specie = widget.controller.profile.specie.name;
    return specie.trim().isEmpty ? 'dog' : specie.trim().toLowerCase();
  }

  String get _riveAssetPath => 'assets/rive/pet/$_specieKey.riv';

  @override
  void initState() {
    super.initState();
    if (widget.controller.hasLoadedProfile) {
      _load();
    } else {
      // The controller's `profile.specie` is just the constructor's
      // placeholder (DOG) until its first `loadProfile()` resolves —
      // loading now would race a real species reveal with the placeholder
      // one. Wait for the real profile instead of guessing.
      widget.controller.addListener(_onProfileMaybeLoaded);
    }
  }

  void _onProfileMaybeLoaded() {
    if (!widget.controller.hasLoadedProfile) return;
    widget.controller.removeListener(_onProfileMaybeLoaded);
    _load();
  }

  @override
  void didUpdateWidget(covariant PetRiveCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.profile.specie != widget.controller.profile.specie) {
      _smController?.dispose();
      _smController = null;
      _riveFile = null;
      if (widget.controller.hasLoadedProfile) _load();
    }
  }

  Future<void> _load() async {
    final path = _riveAssetPath;
    if (_knownMissing.contains(path)) return;
    final rig = _rigFor(_specieKey);
    try {
      final file = await RiveFile.asset(path);
      if (rig is _PoseSwapRig && !_posesExistIn(file, rig)) {
        // The file loaded but doesn't have every artboard/state-machine
        // combination this rig expects — `RiveAnimation` throws a hard
        // `FormatException` for an unknown artboard name (unlike a missing
        // state-machine name, which just no-ops), so this has to be
        // verified before ever handing the file to it.
        _knownMissing.add(path);
        return;
      }
      if (mounted) {
        setState(() {
          _riveFile = file;
          _rig = rig;
        });
      }
    } catch (_) {
      // No `.riv` at this path yet (or it failed to parse) — stay on the
      // PetMascotWidget fallback. Deliberately not rethrown: a missing
      // companion asset must never be a fatal error for the screen hosting
      // it (see the accelerometer fix this session for why unawaited
      // platform failures are dangerous here).
      _knownMissing.add(path);
    }
  }

  bool _posesExistIn(RiveFile file, _PoseSwapRig rig) {
    for (final state in PetAnimationState.values) {
      final artboard = file.artboardByName(rig.artboardForState(state));
      if (artboard == null) return false;
      if (artboard.stateMachines.every((sm) => sm.name != rig.stateMachineName)) {
        return false;
      }
    }
    return true;
  }

  void _markMissingAndFallBack() {
    _knownMissing.add(_riveAssetPath);
    if (mounted) setState(() => _riveFile = null);
  }

  void _onRiveInit(Artboard artboard) {
    final rig = _rig;
    switch (rig) {
      case _CompanionRig():
        final controller = StateMachineController.fromArtboard(artboard, rig.stateMachineName);
        if (controller == null) {
          // The file loaded but doesn't expose the expected state machine
          // name — treat it the same as a missing asset rather than
          // showing a static first frame with no reactions.
          _markMissingAndFallBack();
          return;
        }
        artboard.addController(controller);
        _smController = controller;
        _stateInput = controller.findInput<double>('state') as SMINumber?;
        _reducedMotionInput = controller.findInput<bool>('reducedMotion') as SMIBool?;
        _interactingInput = controller.findInput<bool>('interacting') as SMIBool?;
      case _TriggerRig(:final triggerForState):
        final controller = StateMachineController.fromArtboard(artboard, rig.stateMachineName);
        if (controller == null) {
          _markMissingAndFallBack();
          return;
        }
        artboard.addController(controller);
        _smController = controller;
        _triggers.clear();
        for (final state in PetAnimationState.values) {
          final triggerName = triggerForState(state);
          if (triggerName == null) continue;
          final trigger = controller.getTriggerInput(triggerName);
          if (trigger != null) _triggers[state] = trigger;
        }
        // Reflect whatever state the mascot is already in (e.g. resting
        // asleep after a few inactive days) rather than always opening on
        // the rig's built-in idle pose. `_syncInputs` already ran once by
        // the time this fires (`onInit` resolves after the first build,
        // once the artboard is actually mounted) and found `_triggers`
        // empty, so it has to be primed here directly rather than by
        // relying on the next rebuild.
        final state = widget.controller.profile.animationState;
        _lastSyncedState = state;
        _triggers[state]?.fire();
      case _PoseSwapRig():
        // Nothing to configure — each pose artboard autoplays on its own
        // once mounted; `build()` picks which artboard via `artboard:`, and
        // `RiveAnimation` re-initializes (calling this again) whenever that
        // changes.
        break;
    }
  }

  void _syncInputs(BuildContext context) {
    final rig = _rig;
    switch (rig) {
      case _CompanionRig():
        _stateInput?.value = widget.controller.profile.animationState.index.toDouble();
        _reducedMotionInput?.value = MediaQuery.of(context).disableAnimations;
        _interactingInput?.value = widget.interacting;
      case _TriggerRig():
        final state = widget.controller.profile.animationState;
        if (state == _lastSyncedState) return;
        _lastSyncedState = state;
        // Accessibility stand-in for [_CompanionRig]'s `reducedMotion`
        // input, which this rig doesn't expose: skip firing motion
        // triggers entirely rather than play them anyway.
        if (MediaQuery.of(context).disableAnimations) return;
        _triggers[state]?.fire();
      case _PoseSwapRig():
        break; // Handled directly in build() via `artboard:`.
    }
  }

  /// Mirrors [PetMascotWidget]'s own tap-to-pet reaction, so switching a
  /// species over to Rive doesn't change what tapping the companion does in
  /// contexts that still want that behavior (`interactive: true`) — today
  /// that's neither of the two real call sites, both of which pass `false`
  /// and own their own tap handling instead.
  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.controller.triggerEventAnimation(
      PetAnimationState.happy,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onProfileMaybeLoaded);
    _smController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = _riveFile;
    if (file == null) {
      return PetMascotWidget(
        controller: widget.controller,
        size: widget.size,
        interactive: widget.interactive,
      );
    }
    final rig = _rig;

    final content = ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        _syncInputs(context);
        if (rig is _PoseSwapRig) {
          return RiveAnimation.direct(
            file,
            artboard: rig.artboardForState(widget.controller.profile.animationState),
            stateMachines: [rig.stateMachineName],
            fit: BoxFit.contain,
          );
        }
        return RiveAnimation.direct(
          file,
          stateMachines: [rig.stateMachineName],
          fit: BoxFit.contain,
          onInit: _onRiveInit,
        );
      },
    );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: widget.interactive ? GestureDetector(onTap: _handleTap, child: content) : content,
    );
  }
}
