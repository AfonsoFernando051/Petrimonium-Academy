import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_motion.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/module_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_catalog_error_state.dart';
import 'package:petrimonium/features/academy/presentation/widgets/module_card.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The full, flat learning track — every real module across every school,
/// in order, each with its real status (completed/in-progress/available)
/// and, when locked, the real reason why (never just a padlock — see
/// `ModuleCard.missingPrerequisites`). Reached from Home's "Ver todas as
/// escolas" link, a full-screen expansion of the same "Sua trilha" data
/// Home shows a preview of (`KnowledgeMapStrip`) — same
/// `AcademyController`/`ModuleCard` building blocks `SchoolDetailScreen`
/// already uses per-school, just unscoped across the whole catalog.
class AllModulesScreen extends StatefulWidget {
  const AllModulesScreen({super.key, required this.mascotController});

  final MascotController mascotController;

  @override
  State<AllModulesScreen> createState() => _AllModulesScreenState();
}

class _AllModulesScreenState extends State<AllModulesScreen> {
  late final AcademyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AcademyController(
      repository: DI.academyProgressRepository,
      catalogRepository: DI.academyCatalogRepository,
      remoteDataSource: DI.academyRemoteDataSource,
    );
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

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: AppMotion.pageTransition,
    );
  }

  Future<void> _openModule(AcademyModule module) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(ModuleDetailScreen(module: module, mascotController: widget.mascotController)),
    );
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tokens = context.colors;
    final modules = [..._controller.modules]..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Translator.translate(AppStrings.academyAllModulesTitle),
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
      body: CosmicBackground(
        child: SafeArea(
          child: _controller.isLoading || _controller.isCatalogLoading
              ? const AppLoadingIndicator()
              : _controller.snapshot == null
                  ? AcademyCatalogErrorState(onRetry: _controller.load)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        for (final module in modules) ...[
                          ModuleCard(
                            module: module,
                            status: _controller.statusFor(module),
                            completedLessons: _controller.completedLessonCountFor(module),
                            onTap: () => _openModule(module),
                            missingPrerequisites: _controller.missingPrerequisitesFor(module),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
        ),
      ),
    );
  }
}
