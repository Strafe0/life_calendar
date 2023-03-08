import 'package:flutter/material.dart';

const Color poorWeekColor = Color(0xFF606060);
const Color goodWeekColor = Color(0xFF18C248);
const Color badWeekColor = Color(0xFFFC0F00);
const Color futureWeekColor = Color(0xFFb0bec5);
const Color currentWeekColor = Color(0xFF2196f3);

ThemeData lightTheme = ThemeData(
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  ),
);