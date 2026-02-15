import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/services/audio_playback_service.dart';

void main() {
  // Note: AudioPlayer from audioplayers package requires native platform plugins,
  // which are not available in unit tests. Full audio playback testing is done
  // via integration tests that run on a device/emulator.
  //
  // Here we only test the AudioPlaybackException class which doesn't require
  // native plugins.

  group('AudioPlaybackException', () {
    test('toString returns formatted message', () {
      const exception = AudioPlaybackException('Test error');
      expect(exception.toString(), 'AudioPlaybackException: Test error');
    });

    test('message getter returns the message', () {
      const exception = AudioPlaybackException('Test error');
      expect(exception.message, 'Test error');
    });

    test('can be used with throwsA matcher', () {
      expect(
        () => throw const AudioPlaybackException('No audio URL available'),
        throwsA(isA<AudioPlaybackException>()),
      );
    });

    test('exception message contains expected text', () {
      const exception = AudioPlaybackException('No audio URL available');
      expect(exception.message, contains('audio URL'));
    });
  });
}
