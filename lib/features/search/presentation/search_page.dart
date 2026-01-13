import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/market_symbol.dart';
import '../../../core/widgets/app_textfield.dart';
import 'view_models/search_view_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.viewModel,
    required this.existingSymbols,
    required this.onAddSymbol,
  });

  final SearchViewModel viewModel;
  final Set<String> existingSymbols;
  final Future<bool> Function(MarketSymbol) onAddSymbol;

  static SearchViewModel buildViewModel(BuildContext context) {
    final repository = AppScope.of(context).repository;
    return SearchViewModel(repository: repository);
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.searchTitle),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppTextField(
                  controller: _controller,
                  hintText: AppStrings.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: widget.viewModel.search,
                ),
              ),
              if (widget.viewModel.isLoading)
                const LinearProgressIndicator(),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.viewModel.results.length,
                  itemBuilder: (context, index) {
                    final symbol = widget.viewModel.results[index];
                    final isAdded = widget.existingSymbols.contains(symbol.symbol);
                    return ListTile(
                      title: Text(symbol.symbol),
                      subtitle: Text(symbol.displayName),
                      trailing: TextButton(
                        onPressed: isAdded
                            ? null
                            : () => _addSymbol(context, symbol),
                        child: Text(
                          isAdded ? AppStrings.addedAction : AppStrings.addAction,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addSymbol(BuildContext context, MarketSymbol symbol) async {
    final added = await widget.onAddSymbol(symbol);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(added);
  }
}
