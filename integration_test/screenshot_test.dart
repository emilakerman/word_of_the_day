import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:word_of_the_day/main.dart' as app;

/// Integration tests that capture screenshots of the app.
///
/// Run with:
/// ```
/// flutter test integration_test/screenshot_test.dart
/// ```
///
/// Or on a specific device:
/// ```
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_test.dart
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Tests', () {
    testWidgets('capture main screen screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for any animations to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Take screenshot of main screen
      await takeScreenshot(binding, tester, 'main_screen');
    });

    testWidgets('capture settings screen screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to fully load
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Find and tap the settings button
      final settingsButton = find.byIcon(Icons.settings_outlined);
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Wait for settings screen to fully load
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Take screenshot of settings screen
      await takeScreenshot(binding, tester, 'settings_screen');
    });

    testWidgets('capture theme picker screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      final settingsButton = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Wait for settings to load
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Find and tap the Theme tile
      final themeTile = find.text('Theme');
      expect(themeTile, findsOneWidget);
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      // Wait for bottom sheet animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Take screenshot of theme picker
      await takeScreenshot(binding, tester, 'theme_picker');
    });

    testWidgets('capture dark mode screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      final settingsButton = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Wait for settings to load
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap Theme tile
      final themeTile = find.text('Theme');
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      // Select Dark theme
      final darkOption = find.text('Dark');
      expect(darkOption, findsOneWidget);
      await tester.tap(darkOption);
      await tester.pumpAndSettle();

      // Wait for theme to apply
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Take screenshot of settings in dark mode
      await takeScreenshot(binding, tester, 'settings_dark_mode');

      // Go back to main screen
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
      } else {
        // Try the AppBar back button
        final appBarBackButton = find.byIcon(Icons.arrow_back);
        if (appBarBackButton.evaluate().isNotEmpty) {
          await tester.tap(appBarBackButton);
        }
      }
      await tester.pumpAndSettle();

      // Take screenshot of main screen in dark mode
      await takeScreenshot(binding, tester, 'main_screen_dark_mode');
    });
  });
}

/// Takes a screenshot and saves it to the screenshots directory.
Future<void> takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  // Ensure we're on a stable frame
  await tester.pumpAndSettle();

  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }

  // Take the screenshot
  final bytes = await binding.takeScreenshot(name);

  // Save to file (useful for local testing)
  final screenshotsDir = Directory('screenshots');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  final file = File('screenshots/$name.png');
  await file.writeAsBytes(bytes);

  // ignore: avoid_print
  print('Screenshot saved: screenshots/$name.png');
}
