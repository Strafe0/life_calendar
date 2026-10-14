import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/logger/crashlytics_output.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late _MockCrashlytics crashlytics;
  late CrashlyticsOutput output;

  setUp(() {
    crashlytics = _MockCrashlytics();
    output = CrashlyticsOutput(crashlytics: crashlytics);
    when(() => crashlytics.log(any())).thenAnswer((_) async {});
    when(
      () => crashlytics.recordError(
        any<Object?>(),
        any(),
        reason: any<Object?>(named: 'reason'),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async {});
  });

  OutputEvent event(Level level, String message, {Object? error}) =>
      OutputEvent(LogEvent(level, message, error: error), [
        '┌── pretty printed $message',
      ]);

  test('sends warnings as plain log lines', () {
    output.output(event(Level.warning, 'Low disk space'));

    verify(() => crashlytics.log('[warning] Low disk space')).called(1);
    verifyNever(
      () => crashlytics.recordError(
        any<Object?>(),
        any(),
        reason: any<Object?>(named: 'reason'),
        fatal: any(named: 'fatal'),
      ),
    );
  });

  test('records errors as non-fatal with the message as reason', () {
    final error = StateError('broken');

    output.output(event(Level.error, 'Failed to open database', error: error));

    verify(
      () => crashlytics.recordError(
        error,
        null,
        reason: 'Failed to open database',
        fatal: false,
      ),
    ).called(1);
  });

  test('drops SQL arguments that hold user content', () {
    final error = _FakeDatabaseException(
      "DatabaseException(disk I/O error) sql 'UPDATE weeks SET goals = ? "
      "WHERE id = ?' args [[{\"title\":\"Private goal\"}], 7]",
    );

    output.output(event(Level.error, 'Failed to update goals', error: error));

    verify(
      () => crashlytics.recordError(
        "DatabaseException(disk I/O error) sql 'UPDATE weeks SET goals = ? "
        "WHERE id = ?'",
        null,
        reason: 'Failed to update goals',
        fatal: false,
      ),
    ).called(1);
  });

  test('records fatal events as fatal', () {
    output.output(event(Level.fatal, 'Crash'));

    verify(
      () =>
          crashlytics.recordError('Crash', null, reason: 'Crash', fatal: true),
    ).called(1);
  });
}

class _FakeDatabaseException implements Exception {
  _FakeDatabaseException(this._text);

  final String _text;

  @override
  String toString() => _text;
}
