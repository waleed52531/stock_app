import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/data/in_memory_market_repository.dart';
import '../core/data/market_repository.dart';
import '../features/watchlist/presentation/watchlist_page.dart';
import '../features/watchlist/presentation/view_models/watchlist_view_model.dart';
import 'app_scope.dart';
import 'theme/app_theme.dart';

class StockApp extends StatelessWidget {
  const StockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketRepository repository = InMemoryMarketRepository();
    return AppScope(
      repository: repository,
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: AppTheme.light,
        home: WatchlistPage(
          viewModel: WatchlistViewModel(repository: repository),
        ),
      ),
    );
  }
}
