import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900]!,
    scaffoldBackgroundColor: Colors.grey[850]!,
    appBarTheme: AppBarTheme(
      color: Colors.grey[900]!,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.grey[600]!,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[700],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[500]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      labelStyle: const TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.grey[500]),
    ),
  );

}
