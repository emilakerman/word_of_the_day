import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/word.dart';

/// Loads the curated word list from the JSON asset.
///
/// Use this list as an offline fallback when the dictionary API is unavailable.
/// The list contains 365+ words with complete data. Pair with [WordSelectionService]
/// for date-based selection that avoids repeats (one word per day, cycling through the list).
Future<List<Word>> loadCuratedWords() async {
  final String jsonString;
  try {
    jsonString = await rootBundle.loadString('assets/data/curated_words.json');
  } catch (e) {
    throw CuratedWordsLoadException('Failed to load curated words asset: $e');
  }

  final List<dynamic> list;
  try {
    list = jsonDecode(jsonString) as List<dynamic>;
  } on FormatException catch (e) {
    throw CuratedWordsLoadException('Invalid JSON in curated words: $e');
  }

  return list
      .map((e) => Word.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Thrown when the curated words asset cannot be loaded or parsed.
class CuratedWordsLoadException implements Exception {
  final String message;

  const CuratedWordsLoadException(this.message);

  @override
  String toString() => 'CuratedWordsLoadException: $message';
}
