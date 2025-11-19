import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF007bff), // Blue
    hintColor: const Color(0xFF8e8e93), // Grey for hints
    scaffoldBackgroundColor: const Color(0xFFf9f9f9), // Very light grey
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF007bff), // Blue
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFf0f0f0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.black54),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007bff),
      secondary: Color(0xFFc0c0c0),
      background: Color(0xFFf9f9f9),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF007bff), // Blue
    hintColor: const Color(0xFFc0c0c0), // Silver
    scaffoldBackgroundColor: const Color(0xFF000000), // Black
    cardColor: const Color(0xFF1c1c1e), // A slightly lighter black for cards
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF007bff), // Blue
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1c1c1e),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2c2c2e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white54),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF007bff),
      secondary: Color(0xFFc0c0c0),
      background: Color(0xFF000000),
      surface: Color(0xFF1c1c1e),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
  );
}