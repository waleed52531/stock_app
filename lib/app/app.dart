import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/chart/presentation/views/chart_page.dart';
import '../features/market/presentation/views/market_page.dart';
import '../features/news/presentation/views/news_page.dart';
import '../features/sector/presentation/views/sector_page.dart';
import 'theme/app_theme.dart';

class StockApp extends StatelessWidget {
  const StockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _pages = const [
    MarketPage(),
    ChartPage(),
    NewsPage(),
    SectorPage(),
  ];

  final _titles = const [
    AppStrings.marketTitle,
    AppStrings.chartTitle,
    AppStrings.newsTitle,
    AppStrings.sectorTitle,
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: AppStrings.marketNavLabel,
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: AppStrings.chartNavLabel,
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            label: AppStrings.newsNavLabel,
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart),
            label: AppStrings.sectorNavLabel,
          ),
        ],
      ),
    );
  }
}
