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

  /// Loads the saved notification time. Returns default (9:00 AM) if none saved
  /// or on storage errors (graceful degradation).
  Future<TimeOfDay> getNotificationTime() async {
    try {
      final prefs = await _prefs;
      final hour = prefs.getInt(_keyNotificationHour);
      final minute = prefs.getInt(_keyNotificationMinute);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
      return defaultTime;
    } on Exception {
      return defaultTime;
    }
  }

  /// Saves the notification time preference.
  ///
  /// Throws [NotificationPreferenceException] if storage fails.
  Future<void> setNotificationTime(TimeOfDay time) async {
    try {
      final prefs = await _prefs;
      await prefs.setInt(_keyNotificationHour, time.hour);
      await prefs.setInt(_keyNotificationMinute, time.minute);
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
      await prefs.setBool(_keyNotificationsEnabled, enabled);
    } on Exception catch (e) {
      throw NotificationPreferenceException(
          'Failed to save notifications enabled preference: $e');
    }
  }
}
