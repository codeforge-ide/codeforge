import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _ollamaUrlKey = 'ollama_url';
  static const String _lastModelKey = 'last_model';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  ThemeMode get themeMode {
    final value = _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  double get fontSize => _prefs.getDouble(_fontSizeKey) ?? 14.0;

  Future<void> setFontSize(double size) async {
    await _prefs.setDouble(_fontSizeKey, size);
    notifyListeners();
  }

  String get ollamaUrl =>
      _prefs.getString(_ollamaUrlKey) ?? 'http://localhost:11434';

  Future<void> setOllamaUrl(String url) async {
    await _prefs.setString(_ollamaUrlKey, url);
    notifyListeners();
  }

  String? get lastUsedModel => _prefs.getString(_lastModelKey);

  Future<void> setLastUsedModel(String model) async {
    await _prefs.setString(_lastModelKey, model);
    notifyListeners();
  }
}
