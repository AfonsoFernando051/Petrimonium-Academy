import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/mentor/domain/entities/conversation_summary.dart';

class ConversationListTile extends StatelessWidget {
  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final ConversationSummary conversation;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return '${diff.inHours} h';
    if (diff.inDays < 30) return '${diff.inDays} d';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 16,
      borderColor: AppColors.neonCyan.withValues(alpha: 0.2),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title.isEmpty ? '...' : conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      if (conversation.lastMessagePreview != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          conversation.lastMessagePreview!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _relativeTime(conversation.updatedAt),
                  style: TextStyle(color: tokens.textTertiary, fontSize: 11),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: tokens.textSecondary, size: 18),
                  onSelected: (value) {
                    if (value == 'rename') onRename();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text(Translator.translate(AppStrings.mentorRenameConversationTitle)),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(Translator.translate(AppStrings.mentorDeleteConversationButton)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
