import 'package:flutter/material.dart';
import 'screens/chart_tab.dart';
import 'screens/market_tab.dart';
import 'screens/news_tab.dart';
import 'screens/sector_tab.dart';

void main() {
  runApp(const StockApp());
}

class StockApp extends StatelessWidget {
  const StockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
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
    MarketTab(),
    ChartTab(),
    NewsTab(),
    SectorTab(),
  ];

  final _titles = const [
    'Market',
    'Graph',
    'News',
    'Sector performance',
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
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Graph'),
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'News'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Sectors'),
        ],
      ),
    );
  }
}
