/// Stable identity for a Financial Lab simulator. [sourceId] is the backend
/// XP idempotency key (`xp_events.source_id`, see DECISION-037) and the
/// `AppEvent`/analytics-safe string id — never expose `.name`/`.index` for
/// these purposes, since renaming or reordering the enum must never
/// silently change a user's XP ledger key.
enum LabSimulatorId {
  compoundInterest,
  inflation,
  fixedIncome,
  diversification,
  portfolio,
}

extension LabSimulatorSource on LabSimulatorId {
  String get sourceId => switch (this) {
    LabSimulatorId.compoundInterest => 'compound_interest',
    LabSimulatorId.inflation => 'inflation',
    LabSimulatorId.fixedIncome => 'fixed_income',
    LabSimulatorId.diversification => 'diversification',
    LabSimulatorId.portfolio => 'portfolio',
  };
}
