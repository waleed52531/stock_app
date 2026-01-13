class Quote {
  Quote({
    required this.symbol,
    required this.close,
    required this.change,
    required this.changePercent,
    required this.asOfDate,
    required this.fetchedAt,
  });

  final String symbol;
  final double close;
  final double change;
  final double changePercent;
  final DateTime asOfDate;
  final DateTime fetchedAt;
}
