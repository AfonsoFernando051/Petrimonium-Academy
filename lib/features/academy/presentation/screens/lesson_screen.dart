import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lesson_session_controller.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';
import 'package:petrimonium/features/academy/presentation/widgets/lesson_complete_card.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/choice_question_step_view.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/example_step_view.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/explanation_step_view.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/summary_step_view.dart';
import 'package:petrimonium/features/pet/presentation/celebration/module_completion_share_overlay.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The step player: one [LessonStep] at a time, a top progress bar, and a
/// single "Continuar" action that only enables once a question step has been
/// answered correctly — a wrong pick shows feedback and lets the learner
/// retry, but never advances past the question. Ends in [LessonCompleteCard]
/// — a lesson always completes, there is no fail/restart state (see
/// `docs/ACADEMY_ENGINE.md`, no lives/hearts).
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.catalog,
    required this.mascotController,
  });

  final Lesson lesson;

  /// The curriculum snapshot [lesson] was opened from — forwarded to
  /// [LessonSessionController]. Required from the caller rather than
  /// fetched here since every screen that can navigate to a lesson already
  /// has one loaded (see `AcademyController.snapshot`).
  final AcademyCatalogSnapshot catalog;
  final MascotController mascotController;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonSessionController _controller;
  bool _moduleShareShown = false;

  @override
  void initState() {
    super.initState();
    _controller = LessonSessionController(
      lesson: widget.lesson,
      catalog: widget.catalog,
      academyRepository: DI.academyProgressRepository,
      mascotController: widget.mascotController,
      academyRemoteDataSource: DI.academyRemoteDataSource,
    );
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    final error = _controller.completionError;
    if (error != null) {
      GameSnack.show(context, error, isError: true);
      _controller.clearCompletionError();
    }
    setState(() {});
    final moduleTitle = _controller.completedModuleTitle;
    if (_controller.isComplete && moduleTitle != null && !_moduleShareShown) {
      _moduleShareShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierColor: Colors.transparent,
          builder: (_) => ModuleCompletionShareOverlay(
            moduleTitle: moduleTitle,
            mascotController: widget.mascotController,
            onDismiss: () => Navigator.of(context).pop(),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  // Academia is a bottom-nav tab living on the Dashboard's root route (its
  // `IndexedStack` keeps the tab's own state, `_selectedIndex`, alive) —
  // "back to Academia" is just "pop every pushed screen back to that root".
  void _backToAcademy() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: _controller.isComplete
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: AcademyProgressBar(progress: _controller.progress),
              ),
      ),
      body: CosmicBackground(
        // Lesson steps include quiz/exercise questions — the app's most
        // cognitively demanding screen, so it gets the quietest preset.
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: SingleChildScrollView(
                // Rebuilds this screen's chrome (button labels) if the user
                // switches language in Settings mid-lesson.
                child: ValueListenableBuilder<String>(
                  valueListenable: Translator.languageNotifier,
                  builder: (context, _, _) => _controller.isComplete
                      ? _buildComplete(context)
                      : _buildStep(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    final step = _controller.currentStep;
    final Widget stepView = switch (step) {
      ExplanationStep() => ExplanationStepView(step: step),
      ExampleStep() => ExampleStepView(step: step),
      ChoiceQuestionStep() => ChoiceQuestionStepView(
        step: step,
        stepIndex: _controller.currentStepIndex,
        selectedIndex: _controller.selectedOptionIndex,
        hasAnswered: _controller.hasAnswered,
        answeredCorrectly: _controller.answeredCorrectly,
        onSelect: _controller.selectOption,
        mascotController: widget.mascotController,
      ),
      SummaryStep() => SummaryStepView(step: step),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        stepView,
        const SizedBox(height: 32),
        GameButton(
          label: Translator.translate(
            _controller.isLastStep
                ? AppStrings.academyConcludeButton
                : AppStrings.academyContinueButton,
          ),
          isLoading: _controller.isCompleting,
          onPressed: _controller.canAdvance ? _controller.advance : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildComplete(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: LessonCompleteCard(
        lessonTitle: widget.lesson.title,
        xpEarned: widget.lesson.xpReward,
        onContinue: () => _onCompleteContinue(context),
        onBackToAcademy: _backToAcademy,
      ),
    );
  }

  // Chains straight into the next recommended lesson (same resolver the rest
  // of the app uses, see `LessonSessionController.nextLesson`) instead of
  // just popping back — `pushReplacement` so a run of several lessons in a
  // row doesn't grow the nav stack. Falls back to popping once there's
  // nothing left to recommend (course caught up).
  void _onCompleteContinue(BuildContext context) {
    final next = _controller.nextLesson;
    if (next == null) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }
    Navigator.of(context).pushReplacement(
      _fadeRoute(
        LessonScreen(
          lesson: next,
          catalog: widget.catalog,
          mascotController: widget.mascotController,
        ),
      ),
    );
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
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
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
