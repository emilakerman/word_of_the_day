import '../models/word.dart';

/// Service responsible for selecting the Word of the Day.
///
/// The selection algorithm uses a deterministic approach based on the date,
/// ensuring the same word is selected for a given date regardless of when
/// or how many times the app is opened.
class WordSelectionService {
  /// The list of available words to select from
  final List<Word> _words;

  /// Optional start date for the word cycle (defaults to epoch)
  final DateTime _startDate;

  /// Creates a WordSelectionService with the given list of words.
  ///
  /// [words] - The pool of words to select from. Must not be empty.
  /// [startDate] - Optional start date for calculating the word cycle.
  ///               Defaults to January 1, 2024.
  WordSelectionService({
    required List<Word> words,
    DateTime? startDate,
  })  : _words = List.unmodifiable(words),
        _startDate = startDate ?? DateTime(2024, 1, 1),
        assert(words.isNotEmpty, 'Words list must not be empty');

  /// Gets the Word of the Day for today.
  ///
  /// Returns a [Word] with the [date] field set to today's date.
  Word getTodaysWord() {
    return getWordForDate(DateTime.now());
  }

  /// Gets the Word of the Day for a specific date.
  ///
  /// The selection is deterministic - the same date will always
  /// return the same word.
  ///
  /// [date] - The date to get the word for.
  /// Returns a [Word] with the [date] field set to the specified date.
  Word getWordForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final index = _calculateIndexForDate(normalizedDate);
    final word = _words[index];

    return word.copyWith(date: normalizedDate);
  }

  /// Gets words for a range of dates.
  ///
  /// Useful for displaying a history or calendar view of words.
  ///
  /// [startDate] - The start of the date range (inclusive).
  /// [endDate] - The end of the date range (inclusive).
  /// Returns a list of [Word] objects, one for each day in the range.
  List<Word> getWordsForDateRange(DateTime startDate, DateTime endDate) {
    final normalizedStart = _normalizeDate(startDate);
    final normalizedEnd = _normalizeDate(endDate);

    if (normalizedEnd.isBefore(normalizedStart)) {
      throw ArgumentError('endDate must not be before startDate');
    }

    final words = <Word>[];
    var currentDate = normalizedStart;

    while (!currentDate.isAfter(normalizedEnd)) {
      words.add(getWordForDate(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return words;
  }

  /// Gets the next word in the sequence (tomorrow's word).
  Word getNextWord() {
    return getWordForDate(DateTime.now().add(const Duration(days: 1)));
  }

  /// Gets the previous word (yesterday's word).
  Word getPreviousWord() {
    return getWordForDate(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Gets the total number of words available in the pool.
  int get wordCount => _words.length;

  /// Gets the number of days until the word cycle repeats.
  ///
  /// This is equal to the number of words in the pool.
  int get cycleLengthInDays => _words.length;

  /// Gets which day number we are in the current cycle (1-indexed).
  ///
  /// For example, if there are 14 words and today is day 3 of the cycle,
  /// this returns 3.
  int get currentDayInCycle {
    final index = _calculateIndexForDate(_normalizeDate(DateTime.now()));
    return index + 1;
  }

  /// Calculates the index in the word list for a given date.
  ///
  /// Uses modulo arithmetic to cycle through the words,
  /// creating a repeating pattern.
  int _calculateIndexForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final normalizedStartDate = _normalizeDate(_startDate);
    final daysSinceStart = normalizedDate.difference(normalizedStartDate).inDays;
    // Use modulo to cycle through the list, ensuring non-negative index
    return ((daysSinceStart % _words.length) + _words.length) % _words.length;
  }

  /// Normalizes a DateTime to midnight UTC to ensure consistent date comparison.
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }
}

/// Extension to make it easy to create a WordSelectionService
extension WordSelectionServiceExtension on List<Word> {
  /// Creates a WordSelectionService from this list of words.
  WordSelectionService toSelectionService({DateTime? startDate}) {
    return WordSelectionService(words: this, startDate: startDate);
  }
}
