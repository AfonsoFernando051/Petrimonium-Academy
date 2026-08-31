/// Time windows selectable on the Wealth Evolution chart.
///
/// [apiValue] is sent verbatim to `GET /api/investments/history?range=`.
enum HistoryRange {
  d7('7D', '7D'),
  d30('30D', '30D'),
  m3('3M', '3M'),
  m6('6M', '6M'),
  y1('1Y', '1A'),
  y3('3Y', '3A'),
  y5('5Y', '5A'),
  all('ALL', 'Tudo');

  const HistoryRange(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
