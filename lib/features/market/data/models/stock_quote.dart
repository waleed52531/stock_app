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
}
