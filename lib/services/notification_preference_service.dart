import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyNotificationHour = 'notification_hour';
const String _keyNotificationMinute = 'notification_minute';
const String _keyNotificationsEnabled = 'notifications_enabled';

/// Thrown when notification preference storage fails.
class NotificationPreferenceException implements Exception {
  final String message;

  const NotificationPreferenceException(this.message);

  @override
  String toString() => 'NotificationPreferenceException: $message';
}

/// Persists and loads the user's notification time preference.
class NotificationPreferenceService {
  NotificationPreferenceService({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;

  /// Default notification time: 9:00 AM
  static const TimeOfDay defaultTime = TimeOfDay(hour: 9, minute: 0);

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? await SharedPreferences.getInstance();

  /// Loads the saved notification time. Returns default (9:00 AM) if none saved,
  /// values are out of range, or on storage errors (graceful degradation).
  Future<TimeOfDay> getNotificationTime() async {
    try {
      final prefs = await _prefs;
      final hour = prefs.getInt(_keyNotificationHour);
      final minute = prefs.getInt(_keyNotificationMinute);
      if (hour != null && minute != null) {
        // Validate bounds to prevent AssertionError in TimeOfDay constructor
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return defaultTime;
    } catch (_) {
      // Catch all errors including AssertionError for corrupted prefs
      return defaultTime;
    }
  }

  /// Saves the notification time preference.
  ///
  /// Throws [NotificationPreferenceException] if storage fails.
  Future<void> setNotificationTime(TimeOfDay time) async {
    try {
      final prefs = await _prefs;
      final hourSaved = await prefs.setInt(_keyNotificationHour, time.hour);
      final minuteSaved = await prefs.setInt(_keyNotificationMinute, time.minute);
      if (!hourSaved || !minuteSaved) {
        // Attempt to clean up partial writes (best-effort)
        if (hourSaved && !minuteSaved) {
          await prefs.remove(_keyNotificationHour);
        }
        throw const NotificationPreferenceException(
            'Failed to save notification time preference: storage returned false');
      }
    } on NotificationPreferenceException {
      rethrow;
    } on Exception catch (e) {
      throw NotificationPreferenceException(
          'Failed to save notification time preference: $e');
    }
  }

  /// Loads whether notifications are enabled. Returns true by default.
  Future<bool> getNotificationsEnabled() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_keyNotificationsEnabled) ?? true;
    } on Exception {
      return true;
    }
  }

  /// Saves whether notifications are enabled.
  ///
  /// Throws [NotificationPreferenceException] if storage fails.
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await _prefs;
      final success = await prefs.setBool(_keyNotificationsEnabled, enabled);
      if (!success) {
        throw const NotificationPreferenceException(
            'Failed to save notifications enabled preference: storage returned false');
      }
    } on NotificationPreferenceException {
      rethrow;
    } on Exception catch (e) {
      throw NotificationPreferenceException(
          'Failed to save notifications enabled preference: $e');
    }
  }
}
