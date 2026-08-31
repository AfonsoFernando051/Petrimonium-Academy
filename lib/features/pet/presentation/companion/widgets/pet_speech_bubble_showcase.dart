import 'package:flutter/material.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/enums/pet_speech_bubble_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/comic_bubble_painter.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_comic_speech_bubble.dart';

/// Interactive visual showcase widget allowing designers and developers to
/// test and preview all visual states, dynamic text lengths, typewriter reveal,
/// and responsive tail orientations for the Investor Companion speech bubble.
class PetSpeechBubbleShowcaseScreen extends StatefulWidget {
  const PetSpeechBubbleShowcaseScreen({super.key});

  @override
  State<PetSpeechBubbleShowcaseScreen> createState() =>
      _PetSpeechBubbleShowcaseScreenState();
}

class _PetSpeechBubbleShowcaseScreenState
    extends State<PetSpeechBubbleShowcaseScreen> {
  PetSpeechBubbleState _selectedState = PetSpeechBubbleState.idle;
  PetBubbleTailPosition _tailPosition = PetBubbleTailPosition.bottomLeft;
  int _selectedTextLengthIndex = 1; // Medium default
  bool _enableTypewriter = true;
  bool _showAction = true;

  final List<String> _sampleTexts = [
    // Short
    "Welcome back! Ready to continue your investor journey?",
    // Medium
    "Great job! You just learned how bonds work and earned 50 XP.",
    // Long
    "You already understand the basics of fixed income. Let's take the next step together and see how market risk changes your portfolio decisions!",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sampleMessage = PetMessage(
      id: 'showcase_msg',
      context: PetContext.home,
      priority: PetMessagePriority.normal,
      trigger: PetMessageTrigger.pageEnter,
      textKey: 'SHOWCASE_TEXT',
      mood: PetAnimationState.happy,
      action: _showAction
          ? const PetMessageAction(
              labelKey: 'CONTINUE',
              destination: PetContext.academy,
            )
          : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Companion Speech Bubble Showcase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PREVIEW CANVAS ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  PetComicSpeechBubble(
                    key: ValueKey(
                      '${_selectedState.name}_${_selectedTextLengthIndex}_${_enableTypewriter}_$_tailPosition',
                    ),
                    message: PetMessage(
                      id: 'showcase_${_selectedState.name}',
                      context: PetContext.home,
                      priority: PetMessagePriority.normal,
                      trigger: PetMessageTrigger.pageEnter,
                      textKey: _sampleTexts[_selectedTextLengthIndex],
                      mood: PetAnimationState.happy,
                      action: sampleMessage.action,
                    ),
                    overrideState: _selectedState,
                    tailPosition: _tailPosition,
                    enableTypewriter: _enableTypewriter,
                    onDismiss: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bubble dismissed')),
                      );
                    },
                    onAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Action button tapped!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- CONTROLS ---
            Text('Visual State', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PetSpeechBubbleState.values.map((state) {
                return ChoiceChip(
                  label: Text(state.name.toUpperCase()),
                  selected: _selectedState == state,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedState = state);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Text('Text Length', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Short'),
                  selected: _selectedTextLengthIndex == 0,
                  onSelected: (s) => setState(() => _selectedTextLengthIndex = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: _selectedTextLengthIndex == 1,
                  onSelected: (s) => setState(() => _selectedTextLengthIndex = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Long'),
                  selected: _selectedTextLengthIndex == 2,
                  onSelected: (s) => setState(() => _selectedTextLengthIndex = 2),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text('Tail Pointer Position', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PetBubbleTailPosition.values.map((pos) {
                return ChoiceChip(
                  label: Text(pos.name),
                  selected: _tailPosition == pos,
                  onSelected: (selected) {
                    if (selected) setState(() => _tailPosition = pos);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text('Enable Typewriter Reveal'),
              value: _enableTypewriter,
              onChanged: (val) => setState(() => _enableTypewriter = val),
            ),
            SwitchListTile(
              title: const Text('Show Action CTA Button'),
              value: _showAction,
              onChanged: (val) => setState(() => _showAction = val),
            ),
          ],
        ),
      ),
    );
  }
}
