import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/layer_chip.dart';
import 'package:petrimonium/features/mentor/domain/entities/chat_message.dart';
import 'package:petrimonium/features/mentor/domain/services/mentor_reply_layers.dart';

/// A single chat bubble: user messages are a solid neon-gradient pill
/// (right-aligned, plain text), mentor replies are a `GlassCard` with
/// markdown rendering (left-aligned) — mirrors this app's existing split
/// between player-action chrome and system/glass surfaces.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: _isUser ? _buildUserBubble() : _buildMentorBubble(context),
      ),
    );
  }

  Widget _buildUserBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.neonViolet, AppColors.neonPink],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      ),
    );
  }

  Widget _buildMentorBubble(BuildContext context) {
    final tokens = context.colors;
    final borderColor = message.isError
        ? AppColors.warningAmber.withValues(alpha: 0.5)
        : AppColors.neonCyan.withValues(alpha: 0.35);

    final layers = message.isError ? null : MentorReplyLayers.tryParse(message.text);

    return GlassCard(
      borderColor: borderColor,
      borderRadius: 18,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: message.text.isEmpty
          ? const SizedBox(height: 4)
          : layers == null
              ? _markdown(context, message.text)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayerChip(
                      label: Translator.translate(AppStrings.academyContentLabel),
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(height: 8),
                    _markdown(context, layers.content),
                    if (layers.interpretation != null) ...[
                      const SizedBox(height: 14),
                      LayerChip(
                        label: Translator.translate(AppStrings.mentorInterpretationLabel),
                        color: tokens.mentor,
                      ),
                      const SizedBox(height: 8),
                      DefaultTextStyle.merge(
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        child: _markdown(context, layers.interpretation!),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _markdown(BuildContext context, String data) {
    final tokens = context.colors;
    return MarkdownBody(
      data: data,
      selectable: true,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: tokens.textPrimary, fontSize: 14, height: 1.4),
        strong: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        em: TextStyle(color: tokens.textSecondary, fontStyle: FontStyle.italic),
        listBullet: const TextStyle(color: AppColors.neonCyan, fontSize: 14),
        h1: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        h2: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        code: TextStyle(
          color: AppColors.neonCyan,
          fontFamily: 'monospace',
          backgroundColor: tokens.backgroundSecondary.withValues(alpha: 0.5),
        ),
        blockquoteDecoration: BoxDecoration(
          color: tokens.backgroundSecondary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        tableBorder: TableBorder.all(color: tokens.border),
        tableHead: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        tableBody: TextStyle(color: tokens.textSecondary),
      ),
    );
  }
}
