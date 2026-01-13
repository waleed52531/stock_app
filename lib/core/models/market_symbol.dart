class MarketSymbol {
  const MarketSymbol({
    required this.symbol,
    required this.exchange,
    required this.displayName,
  });

  final String symbol;
  final String exchange;
  final String displayName;
}
