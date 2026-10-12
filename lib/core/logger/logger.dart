import 'package:flutter/foundation.dart';
import 'package:life_calendar/core/logger/crashlytics_output.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  // The default filter drops everything in release builds. Keep warnings and
  // errors there so they reach Crashlytics; debug builds use Logger.level.
  filter: ProductionFilter(),
  level: kReleaseMode ? Level.warning : null,
  output: MultiOutput([ConsoleOutput(), CrashlyticsOutput()]),
);
