import 'package:audioplayers/audioplayers.dart';

/// Thrown when audio playback fails.
class AudioPlaybackException implements Exception {
  final String message;

  const AudioPlaybackException(this.message);

  @override
  String toString() => 'AudioPlaybackException: $message';
}

/// Service for playing audio pronunciation from URLs.
///
/// Provides methods to play, pause, stop, and monitor audio playback state.
/// Uses the audioplayers package for cross-platform audio support.
class AudioPlaybackService {
  final AudioPlayer _player;

  /// Whether the service is currently playing audio.
  bool get isPlaying => _player.state == PlayerState.playing;

  /// Whether audio is currently loading.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Stream of playback state changes.
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  /// Creates an [AudioPlaybackService].
  ///
  /// [player] - Optional AudioPlayer instance for dependency injection.
  AudioPlaybackService({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  /// Plays audio from the given URL.
  ///
  /// Throws [AudioPlaybackException] if the URL is null/empty or playback fails.
  Future<void> playFromUrl(String? url) async {
    if (url == null || url.isEmpty) {
      throw const AudioPlaybackException('No audio URL available');
    }

    try {
      _isLoading = true;
      await _player.stop();
      await _player.setSourceUrl(url);
      await _player.resume();
      _isLoading = false;
    } on Exception catch (e) {
      _isLoading = false;
      throw AudioPlaybackException('Failed to play audio: $e');
    }
  }

  /// Stops current audio playback.
  Future<void> stop() async {
    try {
      await _player.stop();
    } on Exception catch (e) {
      throw AudioPlaybackException('Failed to stop audio: $e');
    }
  }

  /// Pauses current audio playback.
  Future<void> pause() async {
    try {
      await _player.pause();
    } on Exception catch (e) {
      throw AudioPlaybackException('Failed to pause audio: $e');
    }
  }

  /// Resumes paused audio playback.
  Future<void> resume() async {
    try {
      await _player.resume();
    } on Exception catch (e) {
      throw AudioPlaybackException('Failed to resume audio: $e');
    }
  }

  /// Disposes of the audio player resources.
  ///
  /// Call this when the service is no longer needed.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
