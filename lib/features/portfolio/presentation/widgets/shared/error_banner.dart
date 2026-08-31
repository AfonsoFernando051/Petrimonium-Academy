import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Small non-blocking banner shown above a tab's content when a refresh
/// fails but cached data is still being displayed — used by Home, Proventos
/// and Missões so a transient network hiccup doesn't replace the whole
/// screen with an error state.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.error.withValues(alpha: 0.1),
      borderColor: tokens.error.withValues(alpha: 0.4),
      borderRadius: 14,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.satellite_alt, color: tokens.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Não foi possível atualizar seus dados. Puxe para atualizar.',
                style: TextStyle(color: tokens.textPrimary, fontSize: 12),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: tokens.error, size: 18),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
