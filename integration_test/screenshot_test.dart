import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:word_of_the_day/main.dart' as app;

/// Integration tests that capture screenshots of the app.
///
/// Run with:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Tests', () {
    // Convert surface once at the start (Android only)
    setUpAll(() async {
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }
    });

    testWidgets('capture main screen screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(seconds: 1));

      await takeScreenshot(binding, tester, 'main_screen');
    });

    testWidgets('capture settings screen screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final settingsButton = find.byIcon(Icons.settings_outlined);
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      await takeScreenshot(binding, tester, 'settings_screen');
    });

    testWidgets('capture theme picker screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final settingsButton = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      final themeTile = find.text('Theme');
      expect(themeTile, findsOneWidget);
      await tester.tap(themeTile);
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      await takeScreenshot(binding, tester, 'theme_picker');
    });

    testWidgets('capture dark mode screenshot', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      final settingsButton = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Open theme picker
      final themeTile = find.text('Theme');
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      // Select dark theme
      final darkOption = find.text('Dark');
      expect(darkOption, findsOneWidget);
      await tester.tap(darkOption);
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Screenshot settings in dark mode
      await takeScreenshot(binding, tester, 'settings_dark_mode');

      // Navigate back to main screen
      final navigator = Navigator.of(tester.element(find.byType(Scaffold).last));
      navigator.pop();
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Screenshot main screen in dark mode
      await takeScreenshot(binding, tester, 'main_screen_dark_mode');
    });
  });
}

/// Takes a screenshot using the integration test binding.
/// Screenshots are captured by the binding and saved by the test driver.
///
/// Note: On Android, [convertFlutterSurfaceToImage] must be called once
/// before this function (typically in setUpAll).
Future<void> takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pumpAndSettle();
  await binding.takeScreenshot(name);

  // ignore: avoid_print
  print('Screenshot captured: $name');
}
