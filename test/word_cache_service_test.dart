import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_of_the_day/models/word.dart';
import 'package:word_of_the_day/services/word_cache_service.dart';

void main() {
  group('WordCacheService', () {
    late WordCacheService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = WordCacheService(preferences: prefs);
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('getCachedWordForDate returns null when empty', () async {
      final result = await service.getCachedWordForDate(DateTime(2024, 6, 15));
      expect(result, isNull);
    });

    test('saveWordForDate and getCachedWordForDate round-trip', () async {
      const word = Word(
        word: 'Test',
        definition: 'A test definition',
        partOfSpeech: PartOfSpeech.noun,
        pronunciation: '/test/',
        date: null,
      );
      final date = DateTime(2024, 6, 15);

      await service.saveWordForDate(date, word);
      final cached = await service.getCachedWordForDate(date);

      expect(cached, isNotNull);
      expect(cached!.word, word.word);
      expect(cached.definition, word.definition);
      expect(cached.partOfSpeech, word.partOfSpeech);
      expect(cached.pronunciation, word.pronunciation);
      expect(cached.date!.year, date.year);
      expect(cached.date!.month, date.month);
      expect(cached.date!.day, date.day);
    });

    test('getCachedWordForDate returns null for different date', () async {
      const word = Word(
        word: 'Test',
        definition: 'Def',
        partOfSpeech: PartOfSpeech.verb,
      );
      await service.saveWordForDate(DateTime(2024, 6, 15), word);

      final otherDate = await service.getCachedWordForDate(DateTime(2024, 6, 16));
      expect(otherDate, isNull);
    });

    test('saveWordForDate overwrites previous word for same date', () async {
      final date = DateTime(2024, 6, 15);
      await service.saveWordForDate(
        date,
        const Word(
          word: 'First',
          definition: 'First def',
          partOfSpeech: PartOfSpeech.noun,
        ),
      );
      await service.saveWordForDate(
        date,
        const Word(
          word: 'Second',
          definition: 'Second def',
          partOfSpeech: PartOfSpeech.adjective,
        ),
      );

      final cached = await service.getCachedWordForDate(date);
      expect(cached!.word, 'Second');
      expect(cached.definition, 'Second def');
    });

    test('clear removes all cached words', () async {
      await service.saveWordForDate(
        DateTime(2024, 6, 15),
        const Word(
          word: 'A',
          definition: 'Def A',
          partOfSpeech: PartOfSpeech.noun,
        ),
      );

      await service.clear();

      final cached = await service.getCachedWordForDate(DateTime(2024, 6, 15));
      expect(cached, isNull);
    });

    test('removeWordForDate removes entry for that date', () async {
      final date = DateTime(2024, 6, 15);
      await service.saveWordForDate(
        date,
        const Word(
          word: 'Remove',
          definition: 'Def',
          partOfSpeech: PartOfSpeech.noun,
        ),
      );

      await service.removeWordForDate(date);

      final cached = await service.getCachedWordForDate(date);
      expect(cached, isNull);
    });
  });
}
