import 'package:flutter/material.dart';

import '../core/data/market_repository.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final MarketRepository repository;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
