import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_of_the_day/services/notification_preference_service.dart';

void main() {
  group('NotificationPreferenceService', () {
    late NotificationPreferenceService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = NotificationPreferenceService(preferences: prefs);
    });

    tearDown(() async {
      await prefs.clear();
    });

    group('notification time', () {
      test('getNotificationTime returns default (9:00 AM) when no preference saved', () async {
        final result = await service.getNotificationTime();
        expect(result.hour, 9);
        expect(result.minute, 0);
      });

      test('setNotificationTime and getNotificationTime round-trip', () async {
        const time = TimeOfDay(hour: 14, minute: 30);
        await service.setNotificationTime(time);
        final result = await service.getNotificationTime();
        expect(result.hour, 14);
        expect(result.minute, 30);
      });

      test('setNotificationTime overwrites previous preference', () async {
        await service.setNotificationTime(const TimeOfDay(hour: 8, minute: 0));
        await service.setNotificationTime(const TimeOfDay(hour: 20, minute: 45));
        final result = await service.getNotificationTime();
        expect(result.hour, 20);
        expect(result.minute, 45);
      });

      test('preferences persist across service instances', () async {
        const time = TimeOfDay(hour: 7, minute: 15);
        await service.setNotificationTime(time);

        // Create a new service instance with the same SharedPreferences
        final newService = NotificationPreferenceService(preferences: prefs);
        final result = await newService.getNotificationTime();

        expect(result.hour, 7);
        expect(result.minute, 15);
      });

      test('getNotificationTime returns default when only hour is saved', () async {
        // Manually set only hour in SharedPreferences
        await prefs.setInt('notification_hour', 10);

        final result = await service.getNotificationTime();
        // Should return default since minute is missing
        expect(result.hour, 9);
        expect(result.minute, 0);
      });

      test('getNotificationTime returns default when only minute is saved', () async {
        // Manually set only minute in SharedPreferences
        await prefs.setInt('notification_minute', 30);

        final result = await service.getNotificationTime();
        // Should return default since hour is missing
        expect(result.hour, 9);
        expect(result.minute, 0);
      });

      test('handles midnight (00:00) correctly', () async {
        const time = TimeOfDay(hour: 0, minute: 0);
        await service.setNotificationTime(time);
        final result = await service.getNotificationTime();
        expect(result.hour, 0);
        expect(result.minute, 0);
      });

      test('handles end of day (23:59) correctly', () async {
        const time = TimeOfDay(hour: 23, minute: 59);
        await service.setNotificationTime(time);
        final result = await service.getNotificationTime();
        expect(result.hour, 23);
        expect(result.minute, 59);
      });
    });

    group('notifications enabled', () {
      test('getNotificationsEnabled returns true by default', () async {
        final result = await service.getNotificationsEnabled();
        expect(result, true);
      });

      test('setNotificationsEnabled and getNotificationsEnabled round-trip for false', () async {
        await service.setNotificationsEnabled(false);
        final result = await service.getNotificationsEnabled();
        expect(result, false);
      });

      test('setNotificationsEnabled and getNotificationsEnabled round-trip for true', () async {
        // First set to false
        await service.setNotificationsEnabled(false);
        // Then set back to true
        await service.setNotificationsEnabled(true);
        final result = await service.getNotificationsEnabled();
        expect(result, true);
      });

      test('setNotificationsEnabled overwrites previous preference', () async {
        await service.setNotificationsEnabled(false);
        await service.setNotificationsEnabled(true);
        final result = await service.getNotificationsEnabled();
        expect(result, true);
      });

      test('notifications enabled preference persists across service instances', () async {
        await service.setNotificationsEnabled(false);

        // Create a new service instance with the same SharedPreferences
        final newService = NotificationPreferenceService(preferences: prefs);
        final result = await newService.getNotificationsEnabled();

        expect(result, false);
      });
    });

    group('defaultTime', () {
      test('defaultTime is 9:00 AM', () {
        expect(NotificationPreferenceService.defaultTime.hour, 9);
        expect(NotificationPreferenceService.defaultTime.minute, 0);
      });
    });
  });

  group('NotificationPreferenceException', () {
    test('toString returns formatted message', () {
      const exception = NotificationPreferenceException('Test error message');
      expect(exception.toString(), 'NotificationPreferenceException: Test error message');
    });

    test('message property is accessible', () {
      const exception = NotificationPreferenceException('Test error');
      expect(exception.message, 'Test error');
    });
  });
}
