import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_of_the_day/services/theme_preference_service.dart';

void main() {
  group('ThemePreferenceService', () {
    late ThemePreferenceService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = ThemePreferenceService(preferences: prefs);
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('getThemeMode returns ThemeMode.system when no preference saved', () async {
      final result = await service.getThemeMode();
      expect(result, ThemeMode.system);
    });

    test('setThemeMode and getThemeMode round-trip for ThemeMode.light', () async {
      await service.setThemeMode(ThemeMode.light);
      final result = await service.getThemeMode();
      expect(result, ThemeMode.light);
    });

    test('setThemeMode and getThemeMode round-trip for ThemeMode.dark', () async {
      await service.setThemeMode(ThemeMode.dark);
      final result = await service.getThemeMode();
      expect(result, ThemeMode.dark);
    });

    test('setThemeMode and getThemeMode round-trip for ThemeMode.system', () async {
      // First set a different mode
      await service.setThemeMode(ThemeMode.dark);
      // Then set back to system
      await service.setThemeMode(ThemeMode.system);
      final result = await service.getThemeMode();
      expect(result, ThemeMode.system);
    });

    test('setThemeMode overwrites previous preference', () async {
      await service.setThemeMode(ThemeMode.light);
      await service.setThemeMode(ThemeMode.dark);
      final result = await service.getThemeMode();
      expect(result, ThemeMode.dark);
    });

    test('preferences persist across service instances', () async {
      await service.setThemeMode(ThemeMode.dark);

      // Create a new service instance with the same SharedPreferences
      final newService = ThemePreferenceService(preferences: prefs);
      final result = await newService.getThemeMode();

      expect(result, ThemeMode.dark);
    });

    test('getThemeMode returns ThemeMode.system for invalid stored value', () async {
      // Manually set an invalid value in SharedPreferences
      await prefs.setString('theme_mode', 'invalid_value');

      final result = await service.getThemeMode();
      expect(result, ThemeMode.system);
    });
  });

  group('ThemePreferenceException', () {
    test('toString returns formatted message', () {
      const exception = ThemePreferenceException('Test error message');
      expect(exception.toString(), 'ThemePreferenceException: Test error message');
    });

    test('message property is accessible', () {
      const exception = ThemePreferenceException('Test error');
      expect(exception.message, 'Test error');
    });
  });
}
