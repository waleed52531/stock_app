import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/quote.dart';
import '../../../core/models/watchlist_item.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_button.dart';
import '../../search/presentation/search_page.dart';
import '../../symbol_detail/presentation/symbol_detail_page.dart';
import 'view_models/watchlist_view_model.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key, required this.viewModel});

  final WatchlistViewModel viewModel;

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  Future<void> _openSearch() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => SearchPage(
          viewModel: SearchPage.buildViewModel(context),
          existingSymbols: widget.viewModel.watchlist
              .map((item) => item.symbol)
              .toSet(),
          onAddSymbol: widget.viewModel.addSymbol,
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    if (added == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Symbol added to watchlist.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.watchlistTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _openSearch,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openSearch,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addSymbol),
          ),
          body: RefreshIndicator(
            onRefresh: widget.viewModel.refreshQuotes,
            child: Column(
              children: [
                if (widget.viewModel.lastRefreshFailed)
                  MaterialBanner(
                    padding: const EdgeInsets.all(12),
                    content: const Text(AppStrings.offlineBanner),
                    actions: [
                      TextButton(
                        onPressed: widget.viewModel.refreshQuotes,
                        child: const Text(AppStrings.retry),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.schedule, size: 18),
                        label: const Text(AppStrings.eodLabel),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildBody(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    AppStrings.dataDisclaimer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.watchlist.isEmpty) {
      return _EmptyState(onAdd: _openSearch);
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: widget.viewModel.watchlist.length,
      onReorder: widget.viewModel.reorderWatchlist,
      itemBuilder: (context, index) {
        final item = widget.viewModel.watchlist[index];
        final quote = widget.viewModel.quotes[item.symbol];
        return _WatchlistTile(
          key: ValueKey(item.symbol),
          item: item,
          quote: quote,
          onTap: () => _openDetail(item, quote),
          onRemove: () => widget.viewModel.removeSymbol(item.symbol),
          formattedTimestamp: widget.viewModel.formatTimestamp(quote?.fetchedAt),
        );
      },
    );
  }

  void _openDetail(WatchlistItem item, Quote? quote) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SymbolDetailPage(
          symbol: item.symbol,
          displayName: item.displayName,
          initialQuote: quote,
        ),
      ),
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  const _WatchlistTile({
    super.key,
    required this.item,
    required this.quote,
    required this.onTap,
    required this.onRemove,
    required this.formattedTimestamp,
  });

  final WatchlistItem item;
  final Quote? quote;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final String formattedTimestamp;

  @override
  Widget build(BuildContext context) {
    final hasQuote = quote != null;
    final changeColor = quote != null && quote!.change >= 0
        ? Colors.green
        : Colors.redAccent;

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(item.symbol),
        subtitle: Text(item.displayName),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hasQuote ? formatCurrency(quote!.close) : '--',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              hasQuote
                  ? '${formatDelta(quote!.change)} (${formatPercent(quote!.changePercent)})'
                  : '--',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: changeColor),
            ),
            Text(
              hasQuote
                  ? '${AppStrings.lastUpdated}: $formattedTimestamp'
                  : AppStrings.lastUpdatedUnavailable,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.emptyWatchlistTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.emptyWatchlistBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: AppStrings.addSymbol,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
