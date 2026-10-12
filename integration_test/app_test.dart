import 'package:integration_test/integration_test.dart';

import 'flows/first_launch.dart';
import 'flows/lifespan.dart';
import 'flows/localization.dart';
import 'flows/migration.dart';
import 'flows/search.dart';
import 'flows/week.dart';

/// One entry point, so the app is built and installed once for all flows.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  firstLaunchTests();
  weekTests();
  lifespanTests();
  searchTests();
  migrationTests();
  localizationTests();
}
