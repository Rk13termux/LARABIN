import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/placeholder_screen.dart';
import 'screens/market_analysis_screen.dart';
import 'screens/education_screen.dart';
import 'screens/trading_journal_screen.dart';
import 'screens/financial_health_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const LarabinApp());
}

class LarabinApp extends StatefulWidget {
  const LarabinApp({super.key});

  @override
  State<LarabinApp> createState() => _LarabinAppState();
}

class _LarabinAppState extends State<LarabinApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Larabin',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: _themeMode,
      home: MainNavigationScreen(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const MainNavigationScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      MarketAnalysisScreen(),
      EducationScreen(),
      TradingJournalScreen(),
      FinancialHealthScreen(),
      SettingsScreen(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.themeMode == ThemeMode.dark,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Larabin'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Alternar modo claro/oscuro',
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menú',
            onSelected: (index) => setState(() => _selectedIndex = index),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Análisis de Mercado'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Educación'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.book),
                  title: Text('Diario de Trading'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: ListTile(
                  leading: Icon(Icons.health_and_safety),
                  title: Text('Salud Financiera'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 4,
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configuración'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: screens[_selectedIndex],
      // Eliminar BottomNavigationBar
      // bottomNavigationBar: ...
    );
  }
}
