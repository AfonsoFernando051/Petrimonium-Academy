import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/features/academy/data/datasources/lab_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Owns Financial Lab completion state — which simulators are done, and the
/// local-first-then-sync flow for completing one — for the lifetime of a
/// [FinancialLabHomeScreen] visit. Mirrors `AcademyController` (list-level
/// state + backend reconciliation) and `LessonSessionController`
/// (`._completeLesson`/`._syncCompletionToBackend`, the per-completion XP
/// flow) exactly (`docs/DECISIONS.md` DECISION-037).
///
/// **The backend is the only source of truth for XP** — this controller
/// never computes or displays XP itself; [MascotController.evaluateEvolution]
/// is the single choke point that emits `XpGainedEvent`/`UserLeveledUpEvent`/
/// `PetEvolvedEvent`, called here only with the server's own `totalXp`.
class LabCompletionController extends ChangeNotifier {
  LabCompletionController({
    required AcademyProgressLocalRepository repository,
    required MascotController mascotController,
    LabRemoteDataSource? remoteDataSource,
  }) : _repository = repository,
       _mascotController = mascotController,
       _remoteDataSource = remoteDataSource;

  final AcademyProgressLocalRepository _repository;
  final MascotController _mascotController;
  final LabRemoteDataSource? _remoteDataSource;

  Set<String> completedSimulatorIds = {};
  bool isLoading = true;

  bool isCompleted(LabSimulatorId id) =>
      completedSimulatorIds.contains(id.sourceId);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    try {
      completedSimulatorIds = await _repository.loadCompletedSimulatorIds();
    } catch (_) {
      // Local storage read failed — keep whatever is already in memory
      // rather than getting stuck on the loading state forever.
    }

    isLoading = false;
    notifyListeners();

    final remote = _remoteDataSource;
    if (remote == null) return;

    // Best-effort reconciliation with the backend (e.g. a simulator
    // completed on another device). Never blocks the initial render.
    try {
      final serverIds = await remote.getCompletedSimulatorIds();
      completedSimulatorIds = await _repository.mergeCompletedSimulatorIds(
        serverIds,
      );
      notifyListeners();
    } catch (_) {
      // Offline or backend unavailable — keep local-only progress.
    }

    await _retryPendingSyncs(remote);
  }

  /// Re-attempts any completions that finished locally but were never
  /// confirmed synced (e.g. [completeSimulator]'s sync step failed while
  /// offline). `completeSimulator` is idempotent on the backend (see
  /// `CompleteSimulatorUseCaseImpl`'s doc comment) — replaying an
  /// already-recorded completion is always safe and just reports zero XP,
  /// so there is no risk of double-granting XP here.
  Future<void> _retryPendingSyncs(LabRemoteDataSource remote) async {
    final pending = await _repository.loadPendingSyncSimulatorIds();
    if (pending.isEmpty) return;

    for (final simulatorId in pending) {
      try {
        await remote.completeSimulator(simulatorId);
        await _repository.clearSimulatorPendingSync(simulatorId);
      } catch (_) {
        // Still offline/unavailable — stays pending, retried on the next load().
      }
    }
  }

  /// Marks [id] completed and grants its XP. Local-first: the completion is
  /// recorded and the Pet event fires before the backend sync is even
  /// attempted, so a killed app or offline session never loses the
  /// completion — only the XP confirmation stays pending, retried by
  /// [load] on the next visit.
  Future<void> completeSimulator(LabSimulatorId id, String resolvedTitle) async {
    if (isCompleted(id)) return;

    completedSimulatorIds = await _repository.markSimulatorCompleted(
      id.sourceId,
    );
    // Recorded before the sync attempt below — if it fails or the app is
    // killed mid-request, the next `load()` still knows to retry it.
    await _repository.markSimulatorPendingSync(id.sourceId);
    notifyListeners();

    AppEventBus.instance.emit(FinancialLabSimulatorCompletedEvent(resolvedTitle));

    final remote = _remoteDataSource;
    if (remote == null) return;
    try {
      final result = await remote.completeSimulator(id.sourceId);
      await _repository.clearSimulatorPendingSync(id.sourceId);
      await _mascotController.evaluateEvolution(
        _mascotController.profile.netWorth,
        result.totalXp,
      );
      notifyListeners();
    } catch (_) {
      // Offline or backend unavailable — stays in the pending-sync set (see
      // markSimulatorPendingSync above), retried on the next load().
    }
  }
}
