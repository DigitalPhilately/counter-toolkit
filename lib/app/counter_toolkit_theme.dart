import 'package:flutter/material.dart';

ThemeData buildCounterToolkitTheme() {
  const ink = Color(0xFF1F2A29);
  const pine = Color(0xFF0F5B57);
  const brass = Color(0xFFC8883C);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: pine,
        brightness: Brightness.light,
      ).copyWith(
        primary: pine,
        onPrimary: Colors.white,
        secondary: brass,
        onSecondary: const Color(0xFF1F1408),
        surface: Colors.white,
        onSurface: ink,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF3EEE5),
    textTheme: ThemeData(
      brightness: Brightness.light,
    ).textTheme.apply(bodyColor: ink, displayColor: ink),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8D0C2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8D0C2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: pine, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF9C3D2A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF9C3D2A), width: 1.6),
      ),
    ),
  );
}
