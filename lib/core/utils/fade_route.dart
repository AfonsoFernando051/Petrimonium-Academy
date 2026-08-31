import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_motion.dart';

/// The app's standard push transition — fade combined with a subtle
/// slide-up — used for every non-modal screen push (Academy, Financial Lab,
/// Profile, ...). Extracted from three verbatim-identical private copies.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
    transitionDuration: AppMotion.pageTransition,
  );
}
