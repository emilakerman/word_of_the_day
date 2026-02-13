import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_of_the_day/models/word.dart';
import 'package:word_of_the_day/services/word_history_service.dart';

void main() {
  group('WordHistoryService', () {
    late WordHistoryService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = WordHistoryService(preferences: prefs);
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('getHistory returns empty when no history', () async {
      final list = await service.getHistory();
      expect(list, isEmpty);
      expect(await service.historyCount, 0);
    });

    test('addWordViewed and getHistory round-trip', () async {
      final word = const Word(
        word: 'Hello',
        definition: 'A greeting',
        partOfSpeech: PartOfSpeech.noun,
      );
      final date = DateTime(2024, 6, 15);

      await service.addWordViewed(date, word);
      final list = await service.getHistory(limit: 10);

      expect(list.length, 1);
      expect(list[0].date.year, date.year);
      expect(list[0].date.month, date.month);
      expect(list[0].date.day, date.day);
      expect(list[0].word.word, word.word);
      expect(await service.historyCount, 1);
    });

    test('getHistory respects offset and limit (pagination)', () async {
      for (var i = 0; i < 5; i++) {
        await service.addWordViewed(
          DateTime(2024, 6, 15 + i),
          Word(
            word: 'Word$i',
            definition: 'Def $i',
            partOfSpeech: PartOfSpeech.noun,
          ),
        );
      }

      final page1 = await service.getHistory(offset: 0, limit: 2);
      expect(page1.length, 2);
      expect(page1[0].word.word, 'Word4');
      expect(page1[1].word.word, 'Word3');

      final page2 = await service.getHistory(offset: 2, limit: 2);
      expect(page2.length, 2);
      expect(page2[0].word.word, 'Word2');
      expect(page2[1].word.word, 'Word1');
    });

    test('adding same date updates entry', () async {
      final date = DateTime(2024, 6, 15);
      await service.addWordViewed(
        date,
        const Word(
          word: 'First',
          definition: 'First def',
          partOfSpeech: PartOfSpeech.noun,
        ),
      );
      await service.addWordViewed(
        date,
        const Word(
          word: 'Second',
          definition: 'Second def',
          partOfSpeech: PartOfSpeech.adjective,
        ),
      );

      final list = await service.getHistory();
      expect(list.length, 1);
      expect(list[0].word.word, 'Second');
    });

    test('clearHistory removes all entries', () async {
      await service.addWordViewed(
        DateTime(2024, 6, 15),
        const Word(
          word: 'A',
          definition: 'Def',
          partOfSpeech: PartOfSpeech.noun,
        ),
      );
      expect(await service.historyCount, 1);

      await service.clearHistory();

      expect(await service.historyCount, 0);
      expect(await service.getHistory(), isEmpty);
    });
  });
}
