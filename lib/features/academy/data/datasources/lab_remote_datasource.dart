import 'dart:convert';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';
import 'package:petrimonium/features/academy/domain/entities/simulator_completion_result.dart';

/// Syncs Financial Lab simulator completions against the backend's
/// authoritative XP ledger (`docs/DECISIONS.md` DECISION-037). Mirrors
/// `AcademyRemoteDataSource.completeLesson`'s contract exactly — callers use
/// this best-effort, a failed/offline sync must never block the local
/// completion flow, which stays the source of truth for the in-session UI
/// regardless of connectivity.
class LabRemoteDataSource {
  final ApiClient apiClient;

  LabRemoteDataSource({required this.apiClient});

  /// Returns the backend's authoritative XP/level after the completion —
  /// never fabricated client-side. The server decides the XP amount from
  /// [SimulatorCatalog]; the client sends only the id.
  Future<SimulatorCompletionResult> completeSimulator(String simulatorId) async {
    final response = await apiClient.post(
      ApiConstants.labSimulatorCompleteEndpoint(simulatorId),
      const {},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback: 'Failed to sync simulator completion. Status Code: ${response.statusCode}',
        ),
      );
    }
    return SimulatorCompletionResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// The set of simulator ids the backend has recorded as completed for the
  /// current user — used to reconcile local storage across devices.
  Future<Set<String>> getCompletedSimulatorIds() async {
    final response = await apiClient.get(ApiConstants.labSimulatorsProgressEndpoint);
    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(
          response,
          fallback: 'Failed to load simulator progress. Status Code: ${response.statusCode}',
        ),
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final ids = data['completedSimulatorIds'] as List<dynamic>? ?? const [];
    return ids.map((id) => id.toString()).toSet();
  }
}
