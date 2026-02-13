import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/models/word.dart';
import 'package:word_of_the_day/services/word_selection_service.dart';

void main() {
  group('WordSelectionService', () {
    late List<Word> testWords;
    late WordSelectionService service;

    setUp(() {
      testWords = [
        const Word(
          word: 'Apple',
          definition: 'A fruit',
          partOfSpeech: PartOfSpeech.noun,
        ),
        const Word(
          word: 'Beautiful',
          definition: 'Pleasing to the eye',
          partOfSpeech: PartOfSpeech.adjective,
        ),
        const Word(
          word: 'Create',
          definition: 'To make something',
          partOfSpeech: PartOfSpeech.verb,
        ),
      ];
      service = WordSelectionService(
        words: testWords,
        startDate: DateTime(2024, 1, 1),
      );
    });

    test('should return a word for today', () {
      final word = service.getTodaysWord();
      final now = DateTime.now();

      expect(word, isNotNull);
      expect(word.date, isNotNull);
      expect(word.date!.year, now.year);
      expect(word.date!.month, now.month);
      expect(word.date!.day, now.day);
    });

    test('should return deterministic word for same date', () {
      final date = DateTime(2024, 6, 15);
      final word1 = service.getWordForDate(date);
      final word2 = service.getWordForDate(date);

      expect(word1.word, equals(word2.word));
      expect(word1.definition, equals(word2.definition));
    });

    test('should cycle through words correctly', () {
      final startDate = DateTime(2024, 1, 1);

      // Get words for first 3 days
      final word1 = service.getWordForDate(startDate);
      final word2 =
          service.getWordForDate(startDate.add(const Duration(days: 1)));
      final word3 =
          service.getWordForDate(startDate.add(const Duration(days: 2)));

      // Each day should have a different word
      expect(word1.word, isNot(equals(word2.word)));
      expect(word2.word, isNot(equals(word3.word)));
      expect(word1.word, isNot(equals(word3.word)));
    });

    test('should repeat cycle after all words are used', () {
      final startDate = DateTime(2024, 1, 1);
      final dayAfterCycle =
          startDate.add(Duration(days: testWords.length));

      final wordDay1 = service.getWordForDate(startDate);
      final wordAfterCycle = service.getWordForDate(dayAfterCycle);

      // Should be the same word after one full cycle
      expect(wordDay1.word, equals(wordAfterCycle.word));
    });

    test('should set date correctly on returned word', () {
      final testDate = DateTime(2024, 3, 15);
      final word = service.getWordForDate(testDate);

      expect(word.date, isNotNull);
      expect(word.date!.year, 2024);
      expect(word.date!.month, 3);
      expect(word.date!.day, 15);
    });

    test('should return correct word count', () {
      expect(service.wordCount, equals(3));
    });

    test('should return correct cycle length', () {
      expect(service.cycleLengthInDays, equals(3));
    });

    test('getWordsForDateRange should return correct number of words', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 5);

      final words = service.getWordsForDateRange(startDate, endDate);

      expect(words.length, equals(5));
    });

    test('getWordsForDateRange should throw for invalid range', () {
      final startDate = DateTime(2024, 1, 5);
      final endDate = DateTime(2024, 1, 1);

      expect(
        () => service.getWordsForDateRange(startDate, endDate),
        throwsArgumentError,
      );
    });

    test('should handle dates before start date', () {
      final dateBeforeStart = DateTime(2023, 12, 31);
      final word = service.getWordForDate(dateBeforeStart);

      expect(word, isNotNull);
      expect(word.date, isNotNull);
    });

    test('extension should create service from list', () {
      final serviceFromExtension = testWords.toSelectionService();

      expect(serviceFromExtension.wordCount, equals(3));
    });
  });
}
