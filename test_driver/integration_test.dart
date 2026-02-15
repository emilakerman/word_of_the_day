import 'package:integration_test/integration_test_driver_extended.dart';

/// Test driver for running integration tests with screenshot support.
///
/// Run with:
/// ```
/// flutter drive \
///   --driver=test_driver/integration_test.dart \
///   --target=integration_test/screenshot_test.dart
/// ```
Future<void> main() => integrationDriver();
