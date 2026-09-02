import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/pet/presentation/companion/rive/pet_rive_companion.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// What real signal chose [HomeMentorCard]'s message — drives the
/// "Why am I seeing this?" reveal, so the reasoning always matches what
/// actually decided the message rather than a generic disclaimer.
enum HomeMentorReason { continueLesson, reviewDue, returning }

class HomeMentorCard extends StatefulWidget {
  const HomeMentorCard({
    super.key,
    required this.mascotController,
    required this.petName,
    required this.message,
    required this.reason,
  });

  final MascotController mascotController;
  final String petName;
  final String message;
  final HomeMentorReason reason;

  @override
  State<HomeMentorCard> createState() => _HomeMentorCardState();
}

class _HomeMentorCardState extends State<HomeMentorCard> {
  bool _showReason = false;

  String get _reasonText => switch (widget.reason) {
        HomeMentorReason.continueLesson => Translator.translate(AppStrings.homeMentorReasonContinue),
        HomeMentorReason.reviewDue => Translator.translate(AppStrings.homeMentorReasonReview),
        HomeMentorReason.returning => Translator.translate(AppStrings.homeMentorReasonReturn),
      };

  /// The itemized citations backing [_reasonText] — what actually fed this
  /// message (lesson consulted, profile/progress signal, internal guide),
  /// so "why am I seeing this?" is auditable rather than a vague sentence.
  List<String> get _reasonSources => switch (widget.reason) {
        HomeMentorReason.continueLesson => [
            Translator.translate(AppStrings.homeMentorSourceContinue1),
            Translator.translate(AppStrings.homeMentorSourceContinue2),
            Translator.translate(AppStrings.homeMentorSourceContinue3),
          ],
        HomeMentorReason.reviewDue => [
            Translator.translate(AppStrings.homeMentorSourceReview1),
            Translator.translate(AppStrings.homeMentorSourceReview2),
            Translator.translate(AppStrings.homeMentorSourceReview3),
          ],
        HomeMentorReason.returning => [
            Translator.translate(AppStrings.homeMentorSourceReturn1),
            Translator.translate(AppStrings.homeMentorSourceReturn2),
            Translator.translate(AppStrings.homeMentorSourceReturn3),
          ],
      };

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      borderColor: tokens.mentor.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: PetRiveCompanion(controller: widget.mascotController, size: 40, interactive: false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.petName,
                  style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.message,
                  style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _showReason = !_showReason),
                  child: Text(
                    Translator.translate(AppStrings.homeMentorWhySeeing),
                    style: TextStyle(color: tokens.mentor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                if (_showReason) ...[
                  const SizedBox(height: 4),
                  Text(_reasonText, style: TextStyle(color: tokens.textTertiary, fontSize: 12, height: 1.3)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: tokens.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translator.translate(AppStrings.homeMentorSourcesLabel).toUpperCase(),
                          style: TextStyle(
                            color: tokens.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        for (final source in _reasonSources)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(color: tokens.primary, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    source,
                                    style: TextStyle(color: tokens.textSecondary, fontSize: 11, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
