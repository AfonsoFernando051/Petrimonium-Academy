import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/module_chip.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/home/presentation/widgets/knowledge_map_strip.dart';

const _module1 = AcademyModule(
  id: 'm1',
  schoolId: 's1',
  title: 'Renda Fixa',
  description: 'desc',
  icon: Icons.savings,
  order: 2,
  contentAvailable: true,
);

const _module2 = AcademyModule(
  id: 'm2',
  schoolId: 's1',
  title: 'Fundamentos',
  description: 'desc',
  icon: Icons.school,
  order: 1,
  contentAvailable: true,
);

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({
    List<AcademyModule> modules = const [_module1, _module2],
    ModuleStatus Function(AcademyModule)? statusFor,
    int Function(AcademyModule)? completedLessonCountFor,
    void Function(AcademyModule)? onTapModule,
    VoidCallback? onViewAll,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: KnowledgeMapStrip(
          modules: modules,
          statusFor: statusFor ?? (_) => ModuleStatus.available,
          completedLessonCountFor: completedLessonCountFor ?? (_) => 0,
          onTapModule: onTapModule ?? (_) {},
          onViewAll: onViewAll ?? () {},
        ),
      ),
    );
  }

  group('KnowledgeMapStrip', () {
    testWidgets('renders the section label, view-all CTA and one chip per module', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('SUA TRILHA DE CONHECIMENTO'), findsOneWidget);
      expect(find.text('Ver trilha completa'), findsOneWidget);
      expect(find.byType(ModuleChip), findsNWidgets(2));
    });

    testWidgets('renders modules sorted by order, not input order', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final chipTitles = tester
          .widgetList<ModuleChip>(find.byType(ModuleChip))
          .map((c) => c.module.title)
          .toList();

      expect(chipTitles, ['Fundamentos', 'Renda Fixa']);
    });

    testWidgets('tapping a chip invokes onTapModule with that module', (tester) async {
      AcademyModule? tapped;
      await tester.pumpWidget(buildTestableWidget(onTapModule: (m) => tapped = m));

      await tester.tap(find.text('Fundamentos'));
      await tester.pump();

      expect(tapped?.id, 'm2');
    });

    testWidgets('tapping "Ver trilha completa" invokes onViewAll', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(onViewAll: () => tapped = true));

      await tester.tap(find.text('Ver trilha completa'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders nothing in the chip row when modules is empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget(modules: const []));

      expect(find.byType(ModuleChip), findsNothing);
      expect(find.text('SUA TRILHA DE CONHECIMENTO'), findsOneWidget);
    });
  });
}
