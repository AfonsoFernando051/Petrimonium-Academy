/// Reactive animation states the mascot can be rendered in.
///
/// [idle], [celebrate], [think], [sleep] and [victory] are driven by app
/// events (see `MascotController.triggerEventAnimation`). [happy] is a
/// short-lived reaction to direct user interaction (tap / pet).
enum PetAnimationState {
  idle,
  celebrate,
  think,
  sleep,
  victory,
  happy,
}

extension PetAnimationStateAsset on PetAnimationState {
  /// File name (without extension) used to look up the Lottie animation
  /// under `assets/mascot/animations/`.
  String get assetKey => name;
}
