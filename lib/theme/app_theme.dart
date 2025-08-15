import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final primary = Colors.lightBlue.shade300;
    return ThemeData(
      primaryColor: primary,
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(primary: primary, secondary: Colors.lightBlue.shade50),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
            color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // warna tombol
          foregroundColor: Colors.white, // warna teks/icon
        ),
      ),
    );
  }
}
