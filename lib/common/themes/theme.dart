import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF5C05AE),
          onPrimary: Colors.white,
          secondary: CupertinoColors.activeOrange,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black));

  ThemeData getDarkTheme() => ThemeData(
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: CupertinoColors.activeBlue,
          onPrimary: Colors.white,
          secondary: CupertinoColors.activeOrange,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFF141414),
          onSurface: Colors.white));
}