/// Named steps on the 2/4pt grid the app already follows by convention
/// (`SizedBox(height: 16)`, `EdgeInsets.all(12)`, etc. scattered everywhere)
/// — this just gives that convention a name so intent ("small gap" vs
/// "section gap") survives at the call site instead of a bare number.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}
