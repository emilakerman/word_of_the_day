import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/services/audio_playback_service.dart';

class MockAudioPlayer extends AudioPlayer {
  bool playCalled = false;
  bool stopCalled = false;
  bool pauseCalled = false;
  bool resumeCalled = false;
  String? lastUrl;
  bool shouldThrowOnPlay = false;

  @override
  Future<void> setSourceUrl(String url, {bool? isLocal}) async {
    if (shouldThrowOnPlay) {
      throw Exception('Simulated playback error');
    }
    lastUrl = url;
  }

  @override
  Future<void> resume() async {
    if (shouldThrowOnPlay) {
      throw Exception('Simulated playback error');
    }
    resumeCalled = true;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }

  @override
  Future<void> pause() async {
    pauseCalled = true;
  }

  @override
  PlayerState get state => PlayerState.stopped;
}

void main() {
  group('AudioPlaybackService', () {
    late MockAudioPlayer mockPlayer;
    late AudioPlaybackService service;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      service = AudioPlaybackService(player: mockPlayer);
    });

    group('playFromUrl', () {
      test('throws exception when URL is null', () async {
        expect(
          () => service.playFromUrl(null),
          throwsA(isA<AudioPlaybackException>()),
        );
      });

      test('throws exception when URL is empty', () async {
        expect(
          () => service.playFromUrl(''),
          throwsA(isA<AudioPlaybackException>()),
        );
      });

      test('plays audio from valid URL', () async {
        const testUrl = 'https://example.com/audio.mp3';
        await service.playFromUrl(testUrl);

        expect(mockPlayer.lastUrl, testUrl);
        expect(mockPlayer.resumeCalled, true);
      });

      test('stops current audio before playing new', () async {
        const testUrl = 'https://example.com/audio.mp3';
        await service.playFromUrl(testUrl);

        expect(mockPlayer.stopCalled, true);
      });

      test('wraps playback errors in AudioPlaybackException', () async {
        mockPlayer.shouldThrowOnPlay = true;

        expect(
          () => service.playFromUrl('https://example.com/audio.mp3'),
          throwsA(isA<AudioPlaybackException>()),
        );
      });
    });

    group('stop', () {
      test('calls stop on player', () async {
        await service.stop();
        expect(mockPlayer.stopCalled, true);
      });
    });

    group('pause', () {
      test('calls pause on player', () async {
        await service.pause();
        expect(mockPlayer.pauseCalled, true);
      });
    });

    group('isPlaying', () {
      test('returns false when stopped', () {
        expect(service.isPlaying, false);
      });
    });

    group('isLoading', () {
      test('returns false initially', () {
        expect(service.isLoading, false);
      });
    });
  });

  group('AudioPlaybackException', () {
    test('toString returns formatted message', () {
      const exception = AudioPlaybackException('Test error');
      expect(exception.toString(), 'AudioPlaybackException: Test error');
    });

    test('message getter returns the message', () {
      const exception = AudioPlaybackException('Test error');
      expect(exception.message, 'Test error');
    });
  });
}
