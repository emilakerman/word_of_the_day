import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'models/word.dart';
import 'screens/word_of_the_day_screen.dart';
import 'screens/word_history_screen.dart';
import 'screens/settings_screen.dart';
import 'data/sample_words.dart';
import 'services/word_selection_service.dart';
import 'services/theme_preference_service.dart';
import 'services/audio_playback_service.dart';
import 'services/word_history_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ThemePreferenceService _themePreference = ThemePreferenceService();
  final WordSelectionService _wordService = WordSelectionService(words: sampleWords);
  final AudioPlaybackService _audioService = AudioPlaybackService();
  final WordHistoryService _historyService = WordHistoryService();
  ThemeMode _themeMode = ThemeMode.system;
  bool _isAudioPlaying = false;
  bool _isAudioLoading = false;

  /// App version string (keep in sync with pubspec.yaml manually)
  static const String _appVersion = '0.1.0';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _setupAudioListener();
    _recordTodaysWordToHistory();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _setupAudioListener() {
    _audioService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  Future<void> _recordTodaysWordToHistory() async {
    final todaysWord = _wordService.getTodaysWord();
    final now = DateTime.now();
    try {
      await _historyService.addWordViewed(now, todaysWord);
    } on WordHistoryException {
      // Silently ignore history storage failures
    }
  }

  Future<void> _loadThemeMode() async {
    final mode = await _themePreference.getThemeMode();
    if (mounted) setState(() => _themeMode = mode);
  }

  Future<void> _onThemeChanged(ThemeMode mode) async {
    await _themePreference.setThemeMode(mode);
    if (mounted) setState(() => _themeMode = mode);
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (_isAudioPlaying) {
      await _audioService.stop();
      return;
    }

    if (audioUrl == null || audioUrl.isEmpty) {
      return;
    }

    setState(() => _isAudioLoading = true);
    try {
      await _audioService.playFromUrl(audioUrl);
    } on AudioPlaybackException {
      // Audio playback failed - silently ignore
    } finally {
      if (mounted) {
        setState(() => _isAudioLoading = false);
      }
    }
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          currentThemeMode: _themeMode,
          onThemeChanged: _onThemeChanged,
          appVersion: _appVersion,
        ),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WordHistoryScreen(
          onWordSelected: (word) => _showWordDetail(context, word),
        ),
      ),
    );
  }

  void _showWordDetail(BuildContext context, Word word) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WordOfTheDayScreen(
          word: word,
          onShare: () {
            // Share functionality to be implemented
          },
          onFavorite: () {
            // Favorite functionality to be implemented
          },
          onPlayAudio: () => _playAudio(word.audioUrl),
          isAudioPlaying: _isAudioPlaying,
          isAudioLoading: _isAudioLoading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todaysWord = _wordService.getTodaysWord();

    return MaterialApp(
      title: 'Word of the Day',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: _themeMode,
      home: Builder(
        builder: (context) => WordOfTheDayScreen(
          word: todaysWord,
          onShare: () {
            // Share functionality to be implemented
          },
          onFavorite: () {
            // Favorite functionality to be implemented
          },
          onSettings: () => _openSettings(context),
          onHistory: () => _openHistory(context),
          onPlayAudio: () => _playAudio(todaysWord.audioUrl),
          isAudioPlaying: _isAudioPlaying,
          isAudioLoading: _isAudioLoading,
        ),
      ),
    );
  }
}
