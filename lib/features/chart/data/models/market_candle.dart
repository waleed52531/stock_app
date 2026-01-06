class MarketCandle {
  const MarketCandle({
    required this.time,
    required this.close,
  });

  final DateTime time;
  final double close;

  factory MarketCandle.fromAgg(Map<String, dynamic> json) {
    final timestamp = (json['t'] as int?) ?? 0;
    final closePrice = (json['c'] ?? 0).toDouble();
    return MarketCandle(
      time: DateTime.fromMillisecondsSinceEpoch(timestamp),
      close: closePrice,
    );
  }

  factory MarketCandle.fromTwelveData(Map<String, dynamic> json) {
    final timestamp = DateTime.tryParse(json['datetime']?.toString() ?? '');
    final closePrice = double.tryParse(json['close']?.toString() ?? '') ?? 0;
    return MarketCandle(
      time: timestamp ?? DateTime.fromMillisecondsSinceEpoch(0),
      close: closePrice,
    );
  }
}
