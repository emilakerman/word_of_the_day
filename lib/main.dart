import 'package:flutter/material.dart';
import 'screens/word_of_the_day_screen.dart';
import 'data/sample_words.dart';
import 'services/word_selection_service.dart';
import 'services/theme_preference_service.dart';

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
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await _themePreference.getThemeMode();
    if (mounted) setState(() => _themeMode = mode);
  }

  Future<void> _onThemeChanged(ThemeMode mode) async {
    await _themePreference.setThemeMode(mode);
    if (mounted) setState(() => _themeMode = mode);
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
      home: WordOfTheDayScreen(
        word: todaysWord,
        onThemeChanged: _onThemeChanged,
        onShare: () {
          // Share functionality to be implemented
        },
        onFavorite: () {
          // Favorite functionality to be implemented
        },
      ),
    );
  }
}
