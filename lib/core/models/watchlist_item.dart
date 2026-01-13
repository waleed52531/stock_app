import 'market_symbol.dart';

class WatchlistItem {
  WatchlistItem({
    required this.symbol,
    required this.exchange,
    required this.displayName,
    required this.sortOrder,
    required this.addedAt,
  });

  factory WatchlistItem.fromSymbol({
    required MarketSymbol symbol,
    required int sortOrder,
  }) {
    return WatchlistItem(
      symbol: symbol.symbol,
      exchange: symbol.exchange,
      displayName: symbol.displayName,
      sortOrder: sortOrder,
      addedAt: DateTime.now(),
    );
  }

  final String symbol;
  final String exchange;
  final String displayName;
  final int sortOrder;
  final DateTime addedAt;

  WatchlistItem copyWith({int? sortOrder}) {
    return WatchlistItem(
      symbol: symbol,
      exchange: exchange,
      displayName: displayName,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt,
    );
  }
}
