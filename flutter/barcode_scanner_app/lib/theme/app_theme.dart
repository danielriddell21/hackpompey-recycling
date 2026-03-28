import 'package:flutter/material.dart';

class AppTheme {
  // Pastel palette
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green600 = Color(0xFF059669);
  static const Color green700 = Color(0xFF047857);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange600 = Color(0xFFC2410C);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue600 = Color(0xFF1D4ED8);
  static const Color brown100 = Color(0xFFFEF3C7);
  static const Color brown600 = Color(0xFFA16207);
  static const Color grey100 = Color(0xFFE5E7EB);
  static const Color bgPage = Color(0xFFF9FAFB);

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: bgPage,
    colorScheme: ColorScheme.fromSeed(seedColor: green600),
    fontFamily: 'Inter',
    // textTheme: const TextTheme(
    //   displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.8), // EcoScan wordmark
    //   titleLarge:    TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5), // screen titles
    //   titleMedium:   TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.3), // card headings
    //   bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400),                      // body / tips
    //   bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400),                      // secondary body
    //   labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w500),                      // buttons
    //   labelMedium:   TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.04), // badges / pills
    //   labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.06), // eyebrows / caps
    // ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Color(0xFF111827),
      ),
    ),
  );
}
