import 'dart:math';

import '../models/chart_range.dart';
import '../models/market_symbol.dart';
import '../models/quote.dart';
import '../models/time_series_point.dart';
import '../models/watchlist_item.dart';
import 'market_repository.dart';

class InMemoryMarketRepository implements MarketRepository {
  InMemoryMarketRepository({DateTime Function()? now})
      : _now = now ?? DateTime.now {
    _seedWatchlist();
  }

  final DateTime Function() _now;
  final Random _random = Random(4);

  final Duration _quoteTtl = const Duration(hours: 12);
  final Duration _seriesTtl = const Duration(hours: 24);

  final List<MarketSymbol> _symbols = const [
    MarketSymbol(symbol: 'HBL', exchange: 'XKAR', displayName: 'Habib Bank'),
    MarketSymbol(symbol: 'PNSC', exchange: 'XKAR', displayName: 'Pakistan National Shipping'),
    MarketSymbol(symbol: 'ENGRO', exchange: 'XKAR', displayName: 'Engro Corporation'),
    MarketSymbol(symbol: 'OGDC', exchange: 'XKAR', displayName: 'Oil & Gas Development'),
    MarketSymbol(symbol: 'LUCK', exchange: 'XKAR', displayName: 'Lucky Cement'),
    MarketSymbol(symbol: 'UBL', exchange: 'XKAR', displayName: 'United Bank Limited'),
    MarketSymbol(symbol: 'PSO', exchange: 'XKAR', displayName: 'Pakistan State Oil'),
    MarketSymbol(symbol: 'FCCL', exchange: 'XKAR', displayName: 'Fauji Cement'),
  ];

  final Map<String, double> _basePrices = const {
    'HBL': 102.4,
    'PNSC': 388.0,
    'ENGRO': 292.8,
    'OGDC': 113.2,
    'LUCK': 515.6,
    'UBL': 148.1,
    'PSO': 176.3,
    'FCCL': 15.2,
  };

  final List<WatchlistItem> _watchlist = [];
  final Map<String, Quote> _quoteCache = {};
  final Map<String, Map<ChartRange, _CachedSeries>> _seriesCache = {};

  void _seedWatchlist() {
    if (_watchlist.isNotEmpty) {
      return;
    }
    for (var i = 0; i < 3; i++) {
      _watchlist.add(
        WatchlistItem.fromSymbol(
          symbol: _symbols[i],
          sortOrder: i,
        ),
      );
    }
  }

  @override
  Future<List<WatchlistItem>> loadWatchlist() async {
    _watchlist.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List<WatchlistItem>.from(_watchlist);
  }

  @override
  Future<bool> addToWatchlist(MarketSymbol symbol) async {
    if (_watchlist.any((item) => item.symbol == symbol.symbol)) {
      return false;
    }
    _watchlist.add(
      WatchlistItem.fromSymbol(symbol: symbol, sortOrder: _watchlist.length),
    );
    return true;
  }

  @override
  Future<void> removeFromWatchlist(String symbol) async {
    _watchlist.removeWhere((item) => item.symbol == symbol);
    for (var i = 0; i < _watchlist.length; i++) {
      _watchlist[i] = _watchlist[i].copyWith(sortOrder: i);
    }
  }

  @override
  Future<void> reorderWatchlist(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _watchlist.removeAt(oldIndex);
    _watchlist.insert(newIndex, item);
    for (var i = 0; i < _watchlist.length; i++) {
      _watchlist[i] = _watchlist[i].copyWith(sortOrder: i);
    }
  }

  @override
  Future<Map<String, Quote>> fetchQuotes(
    List<String> symbols, {
    bool forceRefresh = false,
  }) async {
    final now = _now();
    final results = <String, Quote>{};

    for (final symbol in symbols) {
      final cached = _quoteCache[symbol];
      final isFresh = cached != null && now.difference(cached.fetchedAt) < _quoteTtl;
      if (!forceRefresh && isFresh) {
        results[symbol] = cached;
        continue;
      }

      final base = _basePrices[symbol] ?? 100;
      final change = (_random.nextDouble() * 4) - 2;
      final close = (base + change).clamp(1, 1000).toDouble();
      final percent = (change / base) * 100;
      final quote = Quote(
        symbol: symbol,
        close: close,
        change: change,
        changePercent: percent,
        asOfDate: DateTime(now.year, now.month, now.day),
        fetchedAt: now,
      );
      _quoteCache[symbol] = quote;
      results[symbol] = quote;
    }

    return results;
  }

  @override
  Future<List<TimeSeriesPoint>> fetchTimeSeries(
    String symbol,
    ChartRange range,
  ) async {
    final now = _now();
    final existing = _seriesCache[symbol]?[range];
    if (existing != null && now.difference(existing.fetchedAt) < _seriesTtl) {
      return existing.points;
    }

    final base = _basePrices[symbol] ?? 100;
    final points = <TimeSeriesPoint>[];
    for (var i = range.days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final wave = sin(i / 6) * 2;
      final dailyClose = (base + wave + (_random.nextDouble() - 0.5))
          .clamp(1, 1000)
          .toDouble();
      final dailyOpen = (dailyClose + (_random.nextDouble() - 0.5)).toDouble();
      final high = (max(dailyClose, dailyOpen) + _random.nextDouble()).toDouble();
      final low = (min(dailyClose, dailyOpen) - _random.nextDouble()).toDouble();
      points.add(
        TimeSeriesPoint(
          symbol: symbol,
          date: DateTime(date.year, date.month, date.day),
          open: dailyOpen,
          high: high,
          low: low,
          close: dailyClose,
          volume: 100000 + _random.nextDouble() * 20000,
        ),
      );
    }

    _seriesCache.putIfAbsent(symbol, () => {})[range] = _CachedSeries(
      points: points,
      fetchedAt: now,
    );
    return points;
  }

  @override
  Future<List<MarketSymbol>> searchSymbols(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }
    final lower = trimmed.toLowerCase();
    return _symbols
        .where(
          (symbol) =>
              symbol.symbol.toLowerCase().contains(lower) ||
              symbol.displayName.toLowerCase().contains(lower),
        )
        .toList();
  }
}

class _CachedSeries {
  _CachedSeries({required this.points, required this.fetchedAt});

  final List<TimeSeriesPoint> points;
  final DateTime fetchedAt;
}
