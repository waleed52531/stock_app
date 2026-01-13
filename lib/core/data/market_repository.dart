import '../models/chart_range.dart';
import '../models/market_symbol.dart';
import '../models/quote.dart';
import '../models/time_series_point.dart';
import '../models/watchlist_item.dart';

abstract class MarketRepository {
  Future<List<WatchlistItem>> loadWatchlist();
  Future<bool> addToWatchlist(MarketSymbol symbol);
  Future<void> removeFromWatchlist(String symbol);
  Future<void> reorderWatchlist(int oldIndex, int newIndex);

  Future<Map<String, Quote>> fetchQuotes(
    List<String> symbols, {
    bool forceRefresh = false,
  });

  Future<List<TimeSeriesPoint>> fetchTimeSeries(
    String symbol,
    ChartRange range,
  );

  Future<List<MarketSymbol>> searchSymbols(String query);
}
