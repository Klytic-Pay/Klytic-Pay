import 'package:flutter/material.dart';
import '../widgets/custom_nav_bar_curved.dart';
import 'dashboard_screen.dart';
import 'invoice_list_screen.dart';
import 'payroll_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const InvoiceListScreen(),
      const PayrollScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: CustomNavBarCurved(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
        onFabPressed: () {
          // TODO: implement FAB action if needed
        },
      ),
    );
  }

  void _onItemSelected(int index) {
    setState(() => _currentIndex = index);
  }
}
