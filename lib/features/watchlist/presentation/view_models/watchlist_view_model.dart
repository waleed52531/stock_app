import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/market_repository.dart';
import '../../../../core/models/market_symbol.dart';
import '../../../../core/models/quote.dart';
import '../../../../core/models/watchlist_item.dart';

class WatchlistViewModel extends ChangeNotifier {
  WatchlistViewModel({required MarketRepository repository})
      : _repository = repository;

  final MarketRepository _repository;
  final DateFormat _timestampFormat = DateFormat('MMM d, h:mm a');

  List<WatchlistItem> _watchlist = [];
  Map<String, Quote> _quotes = {};
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _lastRefreshFailed = false;

  List<WatchlistItem> get watchlist => _watchlist;
  Map<String, Quote> get quotes => _quotes;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get lastRefreshFailed => _lastRefreshFailed;

  String formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return '';
    }
    return _timestampFormat.format(timestamp.toLocal());
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _watchlist = await _repository.loadWatchlist();
    if (_watchlist.isNotEmpty) {
      final symbols = _watchlist.map((item) => item.symbol).toList();
      _quotes = await _repository.fetchQuotes(symbols);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshQuotes() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    _lastRefreshFailed = false;
    notifyListeners();

    try {
      final symbols = _watchlist.map((item) => item.symbol).toList();
      _quotes = await _repository.fetchQuotes(symbols, forceRefresh: true);
    } catch (_) {
      _lastRefreshFailed = true;
    }

    _isRefreshing = false;
    notifyListeners();
  }

  Future<bool> addSymbol(MarketSymbol symbol) async {
    final added = await _repository.addToWatchlist(symbol);
    if (added) {
      _watchlist = await _repository.loadWatchlist();
      _quotes = await _repository.fetchQuotes(
        _watchlist.map((item) => item.symbol).toList(),
      );
      notifyListeners();
    }
    return added;
  }

  Future<void> removeSymbol(String symbol) async {
    await _repository.removeFromWatchlist(symbol);
    _watchlist = await _repository.loadWatchlist();
    _quotes.remove(symbol);
    notifyListeners();
  }

  Future<void> reorderWatchlist(int oldIndex, int newIndex) async {
    await _repository.reorderWatchlist(oldIndex, newIndex);
    _watchlist = await _repository.loadWatchlist();
    notifyListeners();
  }
}
