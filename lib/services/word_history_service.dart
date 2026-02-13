import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/word.dart';

const String _historyKey = 'word_history';
const int _maxHistoryEntries = 90;

/// Thrown when word history storage fails.
class WordHistoryException implements Exception {
  final String message;

  const WordHistoryException(this.message);

  @override
  String toString() => 'WordHistoryException: $message';
}

/// Entry for a word viewed on a given date.
class WordHistoryEntry {
  const WordHistoryEntry({required this.date, required this.word});

  final DateTime date;
  final Word word;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().substring(0, 10),
        'word': word.toJson(),
      };

  static WordHistoryEntry fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String;
    final date = DateTime.parse(dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr);
    final word = Word.fromJson(json['word'] as Map<String, dynamic>);
    return WordHistoryEntry(
      date: DateTime.utc(date.year, date.month, date.day),
      word: word.copyWith(date: DateTime.utc(date.year, date.month, date.day)),
    );
  }
}

/// Service for storing and retrieving previously viewed words (word history).
///
/// Stores up to [_maxHistoryEntries] (90) days of words. Newest first.
/// Supports pagination for history retrieval.
class WordHistoryService {
  WordHistoryService({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? await SharedPreferences.getInstance();

  /// Adds a word to history for the given date. If that date already exists, it is updated.
  /// Keeps only the last [_maxHistoryEntries] entries.
  Future<void> addWordViewed(DateTime date, Word word) async {
    try {
      final prefs = await _prefs;
      final list = await _loadEntries(prefs);
      final normalizedDate = DateTime.utc(date.year, date.month, date.day);
      final entry = WordHistoryEntry(
        date: normalizedDate,
        word: word.copyWith(date: normalizedDate),
      );

      list.removeWhere((e) =>
          e.date.year == normalizedDate.year &&
          e.date.month == normalizedDate.month &&
          e.date.day == normalizedDate.day);
      list.insert(0, entry);

      final toKeep = list.take(_maxHistoryEntries).toList();
      await _saveEntries(prefs, toKeep);
    } on Exception catch (e) {
      throw WordHistoryException('Failed to add word to history: $e');
    }
  }

  /// Returns the total number of history entries.
  Future<int> get historyCount async {
    final prefs = await _prefs;
    final list = await _loadEntries(prefs);
    return list.length;
  }

  /// Fetches a page of history. [offset] is the number of entries to skip, [limit] is the page size.
  /// Returns entries newest first. Returns empty list on storage errors.
  Future<List<WordHistoryEntry>> getHistory({int offset = 0, int limit = 20}) async {
    try {
      final prefs = await _prefs;
      final list = await _loadEntries(prefs);
      final end = (offset + limit).clamp(0, list.length);
      final start = offset.clamp(0, list.length);
      if (start >= list.length) return [];
      return list.sublist(start, end);
    } on Exception {
      return [];
    }
  }

  /// Clears all history. Throws [WordHistoryException] on failure.
  Future<void> clearHistory() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_historyKey);
    } on Exception catch (e) {
      throw WordHistoryException('Failed to clear history: $e');
    }
  }

  Future<List<WordHistoryEntry>> _loadEntries(SharedPreferences prefs) async {
    final jsonStr = prefs.getString(_historyKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => WordHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveEntries(
      SharedPreferences prefs, List<WordHistoryEntry> entries) async {
    final list = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(list));
  }
}
