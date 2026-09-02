import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/scanner_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QRStudioApp());
}

class QRStudioApp extends StatelessWidget {
  const QRStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Studio',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5FEF),
        ),
        scaffoldBackgroundColor:
            const Color(0xFFF7F8FC),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    HistoryScreen(),
    ScannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
            ),
            selectedIcon: Icon(
              Icons.history,
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.qr_code_scanner_outlined,
            ),
            selectedIcon: Icon(
              Icons.qr_code_scanner,
            ),
            label: 'Scanner',
          ),
        ],
      ),
    );
  }
}