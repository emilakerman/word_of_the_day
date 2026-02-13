import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/word.dart';

/// Thrown when the dictionary API request fails (e.g. word not found, network error).
class DictionaryApiException implements Exception {
  final String message;
  final int? statusCode;

  const DictionaryApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'DictionaryApiException: $message';
}

/// Service for fetching word data from the Free Dictionary API.
///
/// Uses [Free Dictionary API](https://dictionaryapi.dev/) (no API key required).
/// Implements retry logic and handles rate limits.
class DictionaryApiService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries';
  static const String _defaultLanguage = 'en';

  final http.Client _client;
  final String _language;
  final int _maxRetries;
  final Duration _retryDelay;

  /// Creates a [DictionaryApiService].
  ///
  /// [client] - Optional HTTP client (defaults to [http.Client]).
  /// [language] - Language code for the API (defaults to 'en').
  /// [maxRetries] - Number of retries on failure (defaults to 2).
  /// [retryDelay] - Delay between retries (defaults to 1 second).
  DictionaryApiService({
    http.Client? client,
    String language = _defaultLanguage,
    int maxRetries = 2,
    Duration? retryDelay,
  })  : _client = client ?? http.Client(),
        _language = language,
        _maxRetries = maxRetries,
        _retryDelay = retryDelay ?? const Duration(seconds: 1);

  /// Fetches word data from the dictionary API.
  ///
  /// Returns a [Word] with definition, pronunciation, examples, and audio URL.
  /// Throws [DictionaryApiException] if the word is not found or the request fails.
  Future<Word> fetchWord(String word) async {
    word = word.trim();
    if (word.isEmpty) {
      throw const DictionaryApiException('Word cannot be empty');
    }

    final uri = Uri.parse('$_baseUrl/$_language/${Uri.encodeComponent(word)}');
    Exception? lastException;

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _client.get(uri).timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Request timed out'),
        );

        if (response.statusCode == 404) {
          throw DictionaryApiException('Word not found: $word', 404);
        }

        if (response.statusCode == 429) {
          // Rate limited - wait and retry
          if (attempt < _maxRetries) {
            await Future<void>.delayed(_retryDelay);
            continue;
          }
          throw const DictionaryApiException(
            'Too many requests. Please try again later.',
            429,
          );
        }

        if (response.statusCode != 200) {
          throw DictionaryApiException(
            'API error: ${response.statusCode}',
            response.statusCode,
          );
        }

        return _parseResponse(word, response.body);
      } on DictionaryApiException {
        rethrow;
      } on TimeoutException catch (e) {
        lastException = e;
        if (attempt < _maxRetries) {
          await Future<void>.delayed(_retryDelay);
        }
      } on Exception catch (e) {
        lastException = e;
        if (attempt < _maxRetries) {
          await Future<void>.delayed(_retryDelay);
        }
      }
    }

    throw DictionaryApiException(
      lastException?.toString() ?? 'Unknown error after $_maxRetries retries',
    );
  }

  Word _parseResponse(String requestedWord, String body) {
    final list = _parseJsonList(body);
    if (list.isEmpty) {
      throw DictionaryApiException('No entries found for: $requestedWord');
    }

    final entry = list[0] as Map<String, dynamic>;
    final wordStr = entry['word'] as String? ?? requestedWord;
    final phonetic = entry['phonetic'] as String?;
    final phonetics = entry['phonetics'] as List<dynamic>? ?? [];
    final origin = entry['origin'] as String?;
    final meanings = entry['meanings'] as List<dynamic>? ?? [];

    String? pronunciation = phonetic;
    String? audioUrl;
    for (final p in phonetics) {
      if (p is Map<String, dynamic>) {
        if (pronunciation == null && p['text'] != null) {
          pronunciation = p['text'] as String;
        }
        if (audioUrl == null && p['audio'] != null && (p['audio'] as String).isNotEmpty) {
          audioUrl = p['audio'] as String;
          break;
        }
      }
    }

    String definition = '';
    String? exampleSentence;
    PartOfSpeech partOfSpeech = PartOfSpeech.other;

    if (meanings.isNotEmpty) {
      final firstMeaning = meanings[0] as Map<String, dynamic>;
      partOfSpeech = PartOfSpeech.fromString(
        firstMeaning['partOfSpeech'] as String? ?? 'other',
      );
      final definitions = firstMeaning['definitions'] as List<dynamic>? ?? [];
      if (definitions.isNotEmpty) {
        final firstDef = definitions[0] as Map<String, dynamic>;
        definition = firstDef['definition'] as String? ?? '';
        exampleSentence = firstDef['example'] as String?;
      }
    }

    if (definition.isEmpty) {
      throw DictionaryApiException('No definition found for: $requestedWord');
    }

    return Word(
      word: wordStr,
      definition: definition,
      partOfSpeech: partOfSpeech,
      pronunciation: pronunciation,
      exampleSentence: exampleSentence,
      audioUrl: audioUrl,
      etymology: origin,
    );
  }

  List<dynamic> _parseJsonList(String body) {
    final decoded = _decodeJson(body);
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) return [decoded];
    return [];
  }

  dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const DictionaryApiException('Invalid API response');
    }
  }
}
