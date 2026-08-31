import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_color_tokens.dart';
import 'login_form.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Center(
      child: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                    color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.06 : 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.goldenBorder.withValues(alpha: 0.5), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadow,
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Large integrated Fox Image with ShaderMask fading out (shows 100% of image)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.white, Colors.transparent],
                              stops: [0.0, 0.7, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            'assets/images/magic_fox.jpg',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image, color: tokens.textTertiary, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                      // Responsive: form starts below the image (340px card width, aspect ~1.2)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // fox image is fitWidth on a 340px card: width=340, natural ratio ~0.78h
                          final imageH = constraints.maxWidth * 0.78;
                          return Padding(
                            padding: EdgeInsets.fromLTRB(24, imageH * 0.75, 24, 32),
                            child: const LoginForm(),
                          );
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
           // Floating avatar top icon
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.2 : 0.85),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: Icon(Icons.person_outline, size: 36, color: tokens.textPrimary),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
