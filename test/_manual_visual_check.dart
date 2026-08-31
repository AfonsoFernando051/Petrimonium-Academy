// Throwaway visual-verification harness — not part of the permanent suite.
// Renders the real PortfolioActivationView steps and captures PNGs so they
// can be inspected without a live backend/login flow (same
// RenderRepaintBoundary technique used in DECISION-034).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/portfolio_activation_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMascotRepository implements MascotRepository {
  @override
  Future<PetProfile> loadProfile() async => PetProfile();
  @override
  Future<void> saveName(String name) async {}
  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}
  @override
  Future<void> saveXp(int xp) async {}
  @override
  Future<void> saveSpecie(PetSpecieEnum specie) async {}
  @override
  Future<void> saveNetWorth(double netWorth) async {}
  @override
  Future<void> saveEquippedAccessories(Map<AccessoryType, PetAccessoryId> equipped) async {}
  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}
  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

Future<void> _capture(WidgetTester tester, String filename) async {
  final RenderRepaintBoundary boundary = tester.renderObject(find.byType(RepaintBoundary).first);
  final image = await boundary.toImage(pixelRatio: 2.0);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(
    '/tmp/claude-1000/-home-fernando-eclipse-workspace-Invest-Game-V2/54ae5aca-15e7-43f0-b48d-8f1b7fa0ce2e/scratchpad/$filename',
  );
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture PortfolioActivationView steps', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final mascotController = MascotController(repository: FakeMascotRepository());

    Widget wrap(Widget child) => RepaintBoundary(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: SizedBox(width: 420, height: 800, child: child)),
      ),
    );

    await tester.pumpWidget(
      wrap(
        PortfolioActivationView(mascotController: mascotController, onOpenAcademyTab: () {}),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _capture(tester, 'activation_1_intro.png');

    await tester.tap(find.text('Vamos começar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _capture(tester, 'activation_2_investor_status.png');

    await tester.tap(find.text('Sim, já invisto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _capture(tester, 'activation_3_connect.png');

    // Rebuild fresh for the "Ainda não" branch.
    await tester.pumpWidget(
      wrap(
        PortfolioActivationView(mascotController: mascotController, onOpenAcademyTab: () {}),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Vamos começar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Ainda não'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _capture(tester, 'activation_4_learn.png');

    mascotController.dispose();
  });
}
