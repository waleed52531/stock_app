class StockQuote {
  const StockQuote({
    required this.ticker,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.previousClose,
  });

  final String ticker;
  final double price;
  final double change;
  final double changePercent;
  final double previousClose;

  factory StockQuote.fromSnapshotJson(Map<String, dynamic> json) {
    final currentPrice = (json['lastTrade']?['p'] ?? 0).toDouble();
    final previousClosePrice = (json['prevDay']?['c'] ?? 0).toDouble();
    final changeValue = currentPrice - previousClosePrice;
    final changePercentValue = previousClosePrice == 0
        ? 0
        : (changeValue / previousClosePrice) * 100;
    return StockQuote(
      ticker: json['ticker'] ?? '',
      price: currentPrice,
      change: changeValue,
      changePercent: changePercentValue,
      previousClose: previousClosePrice,
    );
  }

  factory StockQuote.fromPreviousAgg(String ticker, Map<String, dynamic> json) {
    final closePrice = (json['c'] ?? 0).toDouble();
    final openPrice = (json['o'] ?? 0).toDouble();
    final changeValue = closePrice - openPrice;
    final changePercentValue =
        openPrice == 0 ? 0 : (changeValue / openPrice) * 100;
    return StockQuote(
      ticker: ticker,
      price: closePrice,
      change: changeValue,
      changePercent: changePercentValue,
      previousClose: openPrice,
    );
  }

  factory StockQuote.fromTwelveDataQuote(Map<String, dynamic> json) {
    final price = double.tryParse(json['close']?.toString() ?? '') ?? 0;
    final open = double.tryParse(json['open']?.toString() ?? '') ?? 0;
    final previousClose =
        double.tryParse(json['previous_close']?.toString() ?? '') ?? open;
    final changeValue = double.tryParse(json['change']?.toString() ?? '') ??
        (price - previousClose);
    final changePercent = double.tryParse(
          json['percent_change']?.toString() ?? '',
        ) ??
        (previousClose == 0 ? 0 : (changeValue / previousClose) * 100);
    return StockQuote(
      ticker: json['symbol']?.toString() ?? '',
      price: price,
      change: changeValue,
      changePercent: changePercent,
      previousClose: previousClose,
    );
  }
}
