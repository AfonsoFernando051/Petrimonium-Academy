import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/empty_state_view.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/features/mentor/domain/entities/conversation_summary.dart';
import 'package:petrimonium/features/mentor/presentation/controllers/conversation_list_controller.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/conversation_list_tile.dart';

/// History of the user's Mentor conversations. Popping this screen returns
/// either `null` (nothing selected — user just went back), a positive
/// conversation id (resume that conversation), or the reserved sentinel
/// `-1` (start a brand-new chat), which `MentorScreen` interprets.
class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  static const int newConversationSentinel = -1;

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  late final ConversationListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConversationListController(repository: DI.mentorChatRepository);
    _controller.addListener(_onChanged);
    _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rename(ConversationSummary conversation) async {
    final controller = TextEditingController(text: conversation.title);
    final tokens = context.colors;

    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Translator.translate(AppStrings.mentorRenameConversationTitle),
          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: tokens.textPrimary),
          decoration: InputDecoration(hintText: Translator.translate(AppStrings.mentorRenameConversationHint)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translator.translate(AppStrings.cancelButton), style: const TextStyle(color: AppColors.neonCyan)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(Translator.translate(AppStrings.mentorRenameConversationSave), style: const TextStyle(color: AppColors.neonCyan)),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != conversation.title) {
      final success = await _controller.rename(conversation.id, newTitle);
      if (!success && mounted) {
        GameSnack.show(context, Translator.translate(AppStrings.mentorRenameConversationFailed), isError: true);
      }
    }
  }

  Future<void> _confirmDelete(ConversationSummary conversation) async {
    final tokens = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Translator.translate(AppStrings.mentorDeleteConversationTitle),
          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          Translator.translate(AppStrings.mentorDeleteConversationConfirm),
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translator.translate(AppStrings.cancelButton), style: const TextStyle(color: AppColors.neonCyan)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(Translator.translate(AppStrings.mentorDeleteConversationButton), style: TextStyle(color: tokens.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      final success = await _controller.delete(conversation.id);
      if (!success && mounted) {
        GameSnack.show(context, Translator.translate(AppStrings.mentorDeleteConversationFailed), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Translator.translate(AppStrings.mentorConversationHistoryTitle),
          style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, ConversationListScreen.newConversationSentinel),
        backgroundColor: AppColors.neonViolet,
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        label: Text(Translator.translate(AppStrings.mentorNewChatTooltip), style: const TextStyle(color: Colors.white)),
      ),
      body: CosmicBackground(
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const AppLoadingIndicator();
    }

    if (_controller.error != null) {
      return ErrorStateView(message: _controller.error!, onRetry: _controller.load);
    }

    if (_controller.conversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 96),
      itemCount: _controller.conversations.length,
      itemBuilder: (context, index) {
        final conversation = _controller.conversations[index];
        return ConversationListTile(
          conversation: conversation,
          onTap: () => Navigator.pop(context, conversation.id),
          onRename: () => _rename(conversation),
          onDelete: () => _confirmDelete(conversation),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateView(
      icon: Icons.chat_bubble_outline,
      title: Translator.translate(AppStrings.mentorNoConversationsTitle),
      message: Translator.translate(AppStrings.mentorNoConversationsSubtitle),
    );
  }
}
