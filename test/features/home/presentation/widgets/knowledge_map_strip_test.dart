import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
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
  lessonIds: ['l1', 'l2'],
  contentAvailable: true,
);

const _module2 = AcademyModule(
  id: 'm2',
  schoolId: 's1',
  title: 'Fundamentos',
  description: 'desc',
  icon: Icons.school,
  order: 1,
  lessonIds: ['l3', 'l4'],
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
    testWidgets('renders the section label, view-all CTA and one row per module', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('SUA TRILHA'), findsOneWidget);
      expect(find.text('Ver todas as escolas'), findsOneWidget);
      expect(find.text('Renda Fixa'), findsOneWidget);
      expect(find.text('Fundamentos'), findsOneWidget);
    });

    testWidgets('renders modules sorted by order, not input order', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // _module2 ("Fundamentos") has order 1, _module1 ("Renda Fixa") has
      // order 2, but the widget is given them in the opposite order — the
      // rendered vertical position must reflect sorted order regardless.
      final fundamentosY = tester.getTopLeft(find.text('Fundamentos')).dy;
      final rendaFixaY = tester.getTopLeft(find.text('Renda Fixa')).dy;
      expect(fundamentosY, lessThan(rendaFixaY));
    });

    testWidgets('tapping a row invokes onTapModule with that module', (tester) async {
      AcademyModule? tapped;
      await tester.pumpWidget(buildTestableWidget(onTapModule: (m) => tapped = m));

      await tester.tap(find.text('Fundamentos'));
      await tester.pump();

      expect(tapped?.id, 'm2');
    });

    testWidgets('tapping "Ver todas as escolas" invokes onViewAll', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(onViewAll: () => tapped = true));

      await tester.tap(find.text('Ver todas as escolas'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders nothing in the list when modules is empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget(modules: const []));

      expect(find.text('Fundamentos'), findsNothing);
      expect(find.text('Renda Fixa'), findsNothing);
      expect(find.text('SUA TRILHA'), findsOneWidget);
    });
  });
}
