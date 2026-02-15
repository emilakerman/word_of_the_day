import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyThemeMode = 'theme_mode';

/// Thrown when theme preference storage fails.
class ThemePreferenceException implements Exception {
  final String message;

  const ThemePreferenceException(this.message);

  @override
  String toString() => 'ThemePreferenceException: $message';
}

/// Persists and loads the user's theme preference (system, light, dark).
class ThemePreferenceService {
  ThemePreferenceService({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? await SharedPreferences.getInstance();

  static String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  static ThemeMode _stringToMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Loads the saved theme mode. Returns [ThemeMode.system] if none saved
  /// or on storage errors (graceful degradation).
  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await _prefs;
      final value = prefs.getString(_keyThemeMode);
      return value != null ? _stringToMode(value) : ThemeMode.system;
    } on Exception {
      return ThemeMode.system;
    }
  }

  /// Saves the theme mode and persists across app restarts.
  ///
  /// Throws [ThemePreferenceException] if storage fails.
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyThemeMode, _modeToString(mode));
    } on Exception catch (e) {
      throw ThemePreferenceException('Failed to save theme preference: $e');
    }
  }
}
