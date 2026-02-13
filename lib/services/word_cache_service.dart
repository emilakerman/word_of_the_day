import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/word.dart';

/// Thrown when word cache read/write fails.
class WordCacheException implements Exception {
  final String message;

  const WordCacheException(this.message);

  @override
  String toString() => 'WordCacheException: $message';
}

/// Prefix for cache keys. Key format: [_keyPrefix]_YYYY-MM-DD
const String _keyPrefix = 'word_cache';

/// Service for caching the Word of the Day locally using SharedPreferences.
///
/// Cache is keyed by date (YYYY-MM-DD). Invalidation strategy: one cache entry
/// per calendar day; no TTL is used — the key changes each day so the previous
/// day's word remains until overwritten. Call [clear] to remove all cached words.
class WordCacheService {
  WordCacheService({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;

  /// Lazily obtained SharedPreferences instance.
  Future<SharedPreferences> get _prefs async =>
      _preferences ?? await SharedPreferences.getInstance();

  /// Cache key for a given date (UTC date used for consistency).
  static String _cacheKeyForDate(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    final dateStr = utc.toIso8601String().substring(0, 10);
    return '${_keyPrefix}_$dateStr';
  }

  /// Saves the word for the given date. Overwrites any existing cache for that date.
  ///
  /// The word's [Word.date] is ignored; [date] is used as the cache key.
  /// Throws [WordCacheException] if storage fails.
  Future<void> saveWordForDate(DateTime date, Word word) async {
    try {
      final prefs = await _prefs;
      final key = _cacheKeyForDate(date);
      final json = jsonEncode(word.toJson());
      await prefs.setString(key, json);
    } on Exception catch (e) {
      throw WordCacheException('Failed to save word: $e');
    }
  }

  /// Returns the cached word for [date], or null if missing or invalid.
  ///
  /// Returns null on storage errors (graceful degradation).
  Future<Word?> getCachedWordForDate(DateTime date) async {
    try {
      final prefs = await _prefs;
      final key = _cacheKeyForDate(date);
      final jsonStr = prefs.getString(key);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final word = Word.fromJson(map);
      return word.copyWith(date: DateTime.utc(date.year, date.month, date.day));
    } on Exception {
      return null;
    }
  }

  /// Returns the cached word for today (local date), or null.
  Future<Word?> getCachedTodaysWord() async {
    return getCachedWordForDate(DateTime.now());
  }

  /// Removes the cached word for the given date.
  Future<void> removeWordForDate(DateTime date) async {
    try {
      final prefs = await _prefs;
      final key = _cacheKeyForDate(date);
      await prefs.remove(key);
    } on Exception catch (e) {
      throw WordCacheException('Failed to remove cached word: $e');
    }
  }

  /// Clears all word cache entries (any key starting with [_keyPrefix]).
  ///
  /// Throws [WordCacheException] if storage fails.
  Future<void> clear() async {
    try {
      final prefs = await _prefs;
      final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } on Exception catch (e) {
      throw WordCacheException('Failed to clear cache: $e');
    }
  }
}
