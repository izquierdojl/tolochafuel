import 'package:flutter/material.dart';

abstract final class Paleta {
  static const pine950 = Color(0xFF08100B);
  static const pine900 = Color(0xFF0F1A12);
  static const pine800 = Color(0xFF17291C);
  static const pine700 = Color(0xFF203A28);
  static const pine600 = Color(0xFF2C4F38);
  static const pine500 = Color(0xFF3C6A4D);
  static const pine400 = Color(0xFF5F8F73);
  static const pine300 = Color(0xFF8CB29A);
  static const pine200 = Color(0xFFBCD2C4);
  static const pine100 = Color(0xFFDEEAE2);
  static const pine50 = Color(0xFFF0F5F1);
  static const ochre600 = Color(0xFFA67430);
  static const ochre500 = Color(0xFFC0883E);
  static const ochre400 = Color(0xFFD3A568);
  static const ochre300 = Color(0xFFE2C091);
  static const moss500 = Color(0xFF9AAE63);
  static const moss400 = Color(0xFFB4C47E);
}

abstract final class AppTheme {
  static ThemeData get oscuro => _construir(Brightness.dark);
  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData _construir(Brightness brillo) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Paleta.ochre500,
        brightness: brillo,
      ),
      fontFamily: 'Inter',
    );
  }
}
