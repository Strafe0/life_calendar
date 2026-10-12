import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';

class CrashlyticsOutput extends LogOutput {
  CrashlyticsOutput({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics;

  final FirebaseCrashlytics? _crashlytics;

  FirebaseCrashlytics get _instance =>
      _crashlytics ?? FirebaseCrashlytics.instance;

  // sqflite exceptions end with the SQL arguments, which hold the user's
  // goals, events and notes.
  static final _sqlArguments = RegExp(r' args \[.*$', dotAll: true);

  Object _withoutUserData(Object error) {
    final text = error.toString();
    return _sqlArguments.hasMatch(text)
        ? text.replaceFirst(_sqlArguments, '')
        : error;
  }

  @override
  void output(OutputEvent event) {
    // The plain message, not the pretty-printed box with colors and stack.
    final message = '${event.origin.message}';

    if (event.level == Level.error || event.level == Level.fatal) {
      _instance.recordError(
        _withoutUserData(event.origin.error ?? message),
        event.origin.stackTrace,
        reason: message,
        fatal: event.level == Level.fatal,
      );
    } else {
      _instance.log('[${event.level.name}] $message');
    }
  }
}
