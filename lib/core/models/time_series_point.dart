class TimeSeriesPoint {
  TimeSeriesPoint({
    required this.symbol,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  final String symbol;
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
}
