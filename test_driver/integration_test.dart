import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Test driver for running integration tests with screenshot support.
///
/// Run with:
/// ```
/// flutter drive \
///   --driver=test_driver/integration_test.dart \
///   --target=integration_test/screenshot_test.dart \
///   --screenshot=screenshots
/// ```
Future<void> main() => integrationDriver(
      onScreenshot: (String screenshotName, List<int> screenshotBytes, [Map<String, Object?>? args]) async {
        final screenshotsDir = Directory('screenshots');
        if (!screenshotsDir.existsSync()) {
          screenshotsDir.createSync(recursive: true);
        }
        final file = File('screenshots/$screenshotName.png');
        file.writeAsBytesSync(screenshotBytes);
        print('Screenshot saved: screenshots/$screenshotName.png');
        return true;
      },
    );
