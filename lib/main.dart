import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const KlyticPayApp(),
    ),
  );
}

class KlyticPayApp extends StatelessWidget {
  const KlyticPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: MainScreen(
        isDarkMode: themeProvider.themeMode == ThemeMode.dark,
        onThemeChanged: (isDark) {
          themeProvider.setTheme(
            isDark ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
