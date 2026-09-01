import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/utils/translator.dart';
import 'login_form.dart';
import 'signup_form.dart';

/// Flat, edge-to-edge layout (no glass card/floating badge) — mascot + brand
/// title sit directly on [LoginBackground]. Toggles inline between Entrar
/// and Criar conta instead of the old push-a-dialog signup flow, per the
/// Academy design system's login screen.
class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/generated_fox.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.pets, size: 40, color: tokens.mentor);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Translator.translate(AppStrings.brandTitle).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tokens.mentor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 24),
              _AuthModeToggle(
                isLogin: _isLogin,
                onChanged: (isLogin) => setState(() => _isLogin = isLogin),
              ),
              const SizedBox(height: 24),
              if (_isLogin) const LoginForm() else const SignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented Entrar/Criar conta switch — the active side reads as a solid
/// white pill regardless of theme (a deliberate, theme-invariant accent per
/// the design mockup), the track a muted surface behind it.
class _AuthModeToggle extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onChanged;

  const _AuthModeToggle({required this.isLogin, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthModeOption(
              label: Translator.translate(AppStrings.loginButton),
              selected: isLogin,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _AuthModeOption(
              label: Translator.translate(AppStrings.createAccount),
              selected: !isLogin,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthModeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AuthModeOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.black87 : tokens.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
