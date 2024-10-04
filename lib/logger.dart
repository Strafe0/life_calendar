import 'package:logger/logger.dart';

final logger = Logger(
  output: MultiOutput(
    [
      ConsoleOutput(),
      AdvancedFileOutput(path: 'life_calendar_logs'),
    ],
  ),
);
