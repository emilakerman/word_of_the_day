import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/data/curated_words_loader.dart';
import 'package:word_of_the_day/models/word.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('loadCuratedWords', () {
    test('loads at least 365 words from asset', () async {
      final words = await loadCuratedWords();
      expect(words.length, greaterThanOrEqualTo(365));
    });

    test('each word has required fields', () async {
      final words = await loadCuratedWords();
      for (final w in words) {
        expect(w.word, isNotEmpty);
        expect(w.definition, isNotEmpty);
        expect(w.partOfSpeech, isNotNull);
      }
    });

    test('first word matches expected curated content', () async {
      final words = await loadCuratedWords();
      expect(words.first.word, 'Serendipity');
      expect(words.first.partOfSpeech, PartOfSpeech.noun);
      expect(
        words.first.definition,
        contains('occurrence of events by chance'),
      );
    });
  });
}
