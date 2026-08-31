/// Corner-radius scale consolidating the ad hoc `BorderRadius.circular(N)`
/// values found throughout the app (8/12/16/20/24/999 cover the vast
/// majority). Kept as plain doubles rather than `BorderRadius` getters —
/// most call sites either pass a bare radius (e.g. `GlassCard.borderRadius`)
/// or wrap it themselves (`BorderRadius.circular(AppRadii.lg)`), so a double
/// needs no extra unwrapping either way.
class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Fully-rounded "pill" shape — larger than any realistic widget
  /// dimension so `BorderRadius.circular(pill)` always yields a stadium.
  static const double pill = 999;
}
