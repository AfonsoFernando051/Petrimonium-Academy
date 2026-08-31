# Pet companion Rive assets

Drop a species' `.riv` file here as `{specie}.riv` (lowercase — `dog.riv`, `cat.riv`, `wolf.riv`,
`fox.riv`, `bear.riv`, `lion.riv`, `owl.riv`), matching `PetSpecieEnum`/`PetAssets.imageFor`'s
existing naming convention.

The target design and technical contract each file should satisfy — character structure, a
`Companion` state machine, its three inputs (`state`, `reducedMotion`, `interacting`) and their
exact meaning — is specified in `docs/RIVE_PET_COMPANION_BRIEF.md`, not here.

## `dog.riv` and `owl.riv` — stopgaps, not yet contract-compliant

Two species are bundled today, both reference assets copied in as-is rather than real
`Companion`-contract files — see `_RiveCompanionRig` in
`lib/features/pet/presentation/companion/rive/pet_rive_companion.dart` for the full adapter that
wires each one around the target contract. Every other species still has no `.riv` and renders
the `PetMascotWidget` (Lottie/PNG) fallback.

**`dog.riv`** (`assets/rive/tests/pet_cachorro_state_machine.riv`, verbatim):

- Artboard "Pet Cachorro", state machine **"Pet State Machine"** (not `Companion`).
- Five one-shot **trigger** inputs (`Happy`, `Blink`, `Tail Wag`, `Sit`, `Excited`) instead of the
  target's persistent `state` number input — no `reducedMotion`/`interacting` inputs at all.
- No dedicated `sleep` pose; `PetAnimationState.sleep` borrows `Blink` as the closest stand-in.

**`owl.riv`** (the owl mascot expression-pack reference asset, verbatim) is structured completely
differently — no unified state machine or input at all:

- 21 independent artboards, each a self-contained expression (a static-ish pose plus its own tiny
  autoplaying idle loop) with no cross-artboard wiring or listeners — a marketplace "expression
  pack" meant for picking one pose per context, not a single interactive rig.
- Six of those artboards (named `1`, `5`, `10`, `11`, `13`, `14`) are mapped one-per-`PetAnimationState`
  in `_owlArtboardForState`; "switching pose" means mounting a different artboard (`RiveAnimation`'s
  `artboard:` parameter), not driving an input.
- No dedicated `sleep` pose either; artboard `13` (calm, one eye closed, mid-whistle) is the
  closest available stand-in, same reasoning as `dog.riv`'s `Blink`.

Replacing either with a real `Companion`-contract export (see the brief) needs no code changes
beyond deleting that species' entry from `_kRigForSpecie` — `PetRiveCompanion` was written against
the target contract first; the per-species stopgaps are the deviation.

## Wiring (already done for `dog.riv`/`owl.riv`; repeat per new species)

1. Add the file here as `{specie}.riv`. This directory is declared in `pubspec.yaml`'s
   `flutter: assets:` list.
2. Nothing else. `PetRiveCompanion` already tries to load `assets/rive/pet/{specie}.riv` for
   whichever species the current player's pet is, and falls back to `PetMascotWidget` whenever
   that file is missing, fails to parse, or doesn't expose the expected state machine.
