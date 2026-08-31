/// Shared motion constants. Screen-transition durations were previously
/// copy-pasted as a raw `Duration(milliseconds: 350)` literal at each
/// `PageRouteBuilder` call site — naming it here keeps every custom-transition
/// screen in sync if the timing ever needs to change.
class AppMotion {
  AppMotion._();

  static const Duration pageTransition = Duration(milliseconds: 350);
}
