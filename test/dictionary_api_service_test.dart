import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:word_of_the_day/models/word.dart';
import 'package:word_of_the_day/services/dictionary_api_service.dart';

void main() {
  group('DictionaryApiService', () {
    test('fetchWord parses API response into Word', () async {
      const jsonBody = '''
[
  {
    "word": "hello",
    "phonetic": "/he-lo/",
    "phonetics": [
      {"text": "/he-lo/", "audio": "https://example.com/hello.mp3"}
    ],
    "origin": "Early 19th century",
    "meanings": [
      {
        "partOfSpeech": "noun",
        "definitions": [
          {
            "definition": "A greeting or expression of goodwill.",
            "example": "She said hello and waved."
          }
        ]
      }
    ]
  }
]
''';
      final service = DictionaryApiService(
        client: _MockClient(
          (request) async => http.Response.bytes(
            utf8.encode(jsonBody),
            200,
          ),
        ),
      );

      final word = await service.fetchWord('hello');

      expect(word.word, 'hello');
      expect(word.definition, 'A greeting or expression of goodwill.');
      expect(word.pronunciation, '/he-lo/');
      expect(word.audioUrl, 'https://example.com/hello.mp3');
      expect(word.partOfSpeech, PartOfSpeech.noun);
      expect(word.exampleSentence, 'She said hello and waved.');
      expect(word.etymology, 'Early 19th century');
    });

    test('fetchWord throws DictionaryApiException for empty word', () async {
      final service = DictionaryApiService(
        client: _MockClient((_) async => http.Response('', 200)),
      );

      expect(
        () => service.fetchWord('   '),
        throwsA(isA<DictionaryApiException>().having(
          (e) => e.message,
          'message',
          'Word cannot be empty',
        )),
      );
    });

    test('fetchWord throws DictionaryApiException on 404', () async {
      final service = DictionaryApiService(
        client: _MockClient(
          (request) async => http.Response.bytes(
            utf8.encode('{"title": "No Definitions Found","message": "Sorry pal"}'),
            404,
          ),
        ),
      );

      expect(
        service.fetchWord('xyznonexistent'),
        throwsA(isA<DictionaryApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('fetchWord throws on invalid JSON', () async {
      final service = DictionaryApiService(
        client: _MockClient(
          (request) async => http.Response.bytes(
            utf8.encode('not json'),
            200,
          ),
        ),
      );

      expect(
        () => service.fetchWord('hello'),
        throwsA(isA<DictionaryApiException>()),
      );
    });
  });
}

class _MockClient extends http.BaseClient {
  _MockClient(this._handler);

  final Future<http.Response> Function(http.BaseRequest) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
    );
  }
}
