import 'package:flutter/material.dart';

import '../../../../core/data/market_repository.dart';
import '../../../../core/models/market_symbol.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required MarketRepository repository})
      : _repository = repository;

  final MarketRepository _repository;

  bool _isLoading = false;
  List<MarketSymbol> _results = [];

  bool get isLoading => _isLoading;
  List<MarketSymbol> get results => _results;

  Future<void> search(String query) async {
    _isLoading = true;
    notifyListeners();
    _results = await _repository.searchSymbols(query);
    _isLoading = false;
    notifyListeners();
  }
}
