import 'package:flutter/material.dart';

Color redAccent = Color(0xFFFF5252);
Color greenAccent = Color(0xFF2EC91C);

const Color bloodRed = Color(0xFFB11226);
const Color crimsonNeon = Color(0xFFFF1E1E);
const Color infernoOrange = Color(0xFFFF6A00);
const Color electricGold = Color(0xFFFFC400);
const Color poisonGreen = Color(0xFF39FF14);
const Color toxicCyan = Color(0xFF00E5FF);
const Color royalPurple = Color(0xFF7B2CFF);
const Color iceBlue = Color(0xFF4D9FFF);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE10600),
    onPrimary: Colors.white,
    secondary: Color(0xFFFF6A00),
    onSecondary: Colors.white,
    tertiary: Color(0xFF007BFF),
    onTertiary: Colors.white,
    error: Color(0xFFCF2A2A),
    onError: Colors.white,
    surface: Color(0xFF1C1C1E),
    onSurface: Color(0xFFEAEAEA),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF181818),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE10600),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFEAEAEA),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFFCCCCCC),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFFB0B0B0),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF2A2A2A),
    thickness: 1,
  ),
);
