// theme.dart
import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFA61E49),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFA61E49),
    secondary: Color(0xFF1455AC),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFA61E49),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFA61E49),
    secondary: Color(0xFF1455AC),
  ),
);
