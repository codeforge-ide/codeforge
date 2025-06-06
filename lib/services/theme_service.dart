import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  double _fontSize = 14.0;
  String _fontFamily = 'JetBrains Mono';

  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    textTheme: Typography.material2021().white.copyWith(
          bodyMedium: const TextStyle(fontFamily: 'JetBrains Mono'),
          bodyLarge: const TextStyle(fontFamily: 'JetBrains Mono'),
        ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    textTheme: Typography.material2021().black.copyWith(
          bodyMedium: const TextStyle(fontFamily: 'JetBrains Mono'),
          bodyLarge: const TextStyle(fontFamily: 'JetBrains Mono'),
        ),
  );

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setFontSize(double size) {
    if (size >= 8 && size <= 32) {
      _fontSize = size;
      notifyListeners();
    }
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }

  ThemeData get currentTheme =>
      _themeMode == ThemeMode.light ? lightTheme : darkTheme;
}
