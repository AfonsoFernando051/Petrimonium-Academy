import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/utils/game_snack.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/utils/friendly_error_message.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../screens/pet_configuration_screen.dart';
import '../../data/models/question_model.dart';
import '../widgets/question_card.dart';
import '../widgets/submit_assessment_button.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  late Future<List<QuestionModel>> _questionsFuture;
  final Map<String, String> _selectedOptionByQuestionId = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = DI.onboardingRepository.getQuestions();
  }

  Future<void> _handleSubmit(List<QuestionModel> questions) async {
    if (_isSubmitting) return;

    final selectedOptionIds = <String>[];
    for (final q in questions) {
      final selected = _selectedOptionByQuestionId[q.id];
      if (selected == null) {
        GameSnack.show(context, Translator.translate(AppStrings.pleaseAnswerAllQuestions), isError: true);
        return;
      }
      selectedOptionIds.add(selected);
    }

    setState(() => _isSubmitting = true);
    try {
      await DI.onboardingRepository.submitAssessment(selectedOptionIds);
      if (!mounted) return;
      
      final hasPet = await DI.petRepository.getPetStatus();
      if (!mounted) return;

      if (!hasPet) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PetConfigurationScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      GameSnack.show(
        context,
        '${Translator.translate(AppStrings.onboardingFailed)}: ${friendlyErrorMessage(e)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuestionModel>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: AppLoadingIndicator(),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Text(
                '${Translator.translate(AppStrings.failedToLoadQuestions)}: ${friendlyErrorMessage(snapshot.error!)}',
                style: TextStyle(color: context.colors.textPrimary),
              )
            ),
          );
        }
        final questions = snapshot.data ?? [];
        if (questions.isEmpty) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Text(Translator.translate(AppStrings.noQuestionsAvailable), style: TextStyle(color: context.colors.textPrimary))
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final q = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuestionCard(
                  question: q,
                  isFirst: index == 0,
                  selectedOptionId: _selectedOptionByQuestionId[q.id],
                  onSelected: (optionId) {
                    setState(() => _selectedOptionByQuestionId[q.id] = optionId);
                  },
                ),
              );
            }),
            
            const SizedBox(height: 8),
            
            // Submit Button
            SubmitAssessmentButton(
              isSubmitting: _isSubmitting,
              onPressed: () => _handleSubmit(questions),
            ),
            
            const SizedBox(height: 12),
            
            TextButton(
              onPressed: _selectedOptionByQuestionId.isEmpty
                  ? null
                  : () {
                      setState(() => _selectedOptionByQuestionId.clear());
                      GameSnack.show(context, Translator.translate(AppStrings.investorProfileClearAnswers));
                    },
              child: Text(
                Translator.translate(AppStrings.investorProfileClearAnswersButton),
                style: TextStyle(
                  color: context.colors.textTertiary,
                  decoration: TextDecoration.underline,
                  decorationColor: context.colors.textTertiary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
