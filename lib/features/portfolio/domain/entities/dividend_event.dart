// ignore_for_file: constant_identifier_names

/// Mirrors the backend's `DividendType` enum exactly (see
/// `core/domain/enums/DividendType.java`) so `.byName()` round-trips cleanly,
/// matching this codebase's existing convention for backend-sourced enums
/// (e.g. `InvestmentTypeEnum`).
enum DividendType { DIVIDENDO, JCP, RENDIMENTO, OUTRO }

/// Mirrors `DividendRadarEntryDTO`'s `status` field.
enum DividendStatus { ANNOUNCED, PAID }

/// A single confirmed corporate-action payment for a ticker the user really
/// holds, scaled by their real quantity. Unlike `PassiveIncomeEstimate`
/// (projected from an assumed yield), every value here is traced back to a
/// provider-confirmed payment — see `GetDividendRadarUseCaseImpl` on the
/// backend. `paymentDate`/`dataCom`/`approvedOn` may individually be null
/// when the provider hasn't confirmed that particular date yet.
class DividendEvent {
  final String ticker;
  final DividendType type;
  final String rawLabel;
  final double ratePerShare;
  final DateTime? dataCom;
  final DateTime? paymentDate;
  final DateTime? approvedOn;
  final double userQuantity;
  final double estimatedGrossAmount;
  final DividendStatus status;

  const DividendEvent({
    required this.ticker,
    required this.type,
    required this.rawLabel,
    required this.ratePerShare,
    required this.dataCom,
    required this.paymentDate,
    required this.approvedOn,
    required this.userQuantity,
    required this.estimatedGrossAmount,
    required this.status,
  });

  factory DividendEvent.fromJson(Map<String, dynamic> json) {
    return DividendEvent(
      ticker: json['ticker'] as String,
      type: _parseType(json['type'] as String?),
      rawLabel: (json['rawLabel'] as String?) ?? '',
      ratePerShare: (json['ratePerShare'] as num?)?.toDouble() ?? 0.0,
      dataCom: _parseDate(json['dataCom']),
      paymentDate: _parseDate(json['paymentDate']),
      approvedOn: _parseDate(json['approvedOn']),
      userQuantity: (json['userQuantity'] as num?)?.toDouble() ?? 0.0,
      estimatedGrossAmount: (json['estimatedGrossAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] == 'PAID' ? DividendStatus.PAID : DividendStatus.ANNOUNCED,
    );
  }

  static DividendType _parseType(String? raw) {
    if (raw == null) return DividendType.OUTRO;
    return DividendType.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => DividendType.OUTRO,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

/// Wraps `GET /api/investments/dividends` — real confirmed dividend/JCP/yield
/// events for the user's actual holdings, split into what's still ahead and
/// what has already been paid (most recent first).
class DividendRadar {
  final List<DividendEvent> upcoming;
  final List<DividendEvent> history;

  const DividendRadar({required this.upcoming, required this.history});

  static const empty = DividendRadar(upcoming: [], history: []);

  bool get isEmpty => upcoming.isEmpty && history.isEmpty;

  DividendEvent? get nextPayment => upcoming.isEmpty ? null : upcoming.first;

  factory DividendRadar.fromJson(Map<String, dynamic> json) {
    final upcoming = (json['upcoming'] as List<dynamic>? ?? [])
        .map((e) => DividendEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    final history = (json['history'] as List<dynamic>? ?? [])
        .map((e) => DividendEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    return DividendRadar(upcoming: upcoming, history: history);
  }
}
