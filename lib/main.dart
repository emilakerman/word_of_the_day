import 'package:flutter/material.dart';
import 'screens/word_of_the_day_screen.dart';
import 'data/sample_words.dart';
import 'services/word_selection_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a word selection service with sample words
    final wordService = WordSelectionService(words: sampleWords);

    // Get today's word using the selection service
    final todaysWord = wordService.getTodaysWord();

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
      themeMode: ThemeMode.system,
      home: WordOfTheDayScreen(
        word: todaysWord,
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
