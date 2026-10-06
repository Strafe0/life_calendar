import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/extensions/string/string_extension.dart';

void main() {
  test('parses a date with a pattern', () {
    expect(
      '15.05.1990'.toDateTime(pattern: 'dd.MM.yyyy'),
      DateTime(1990, 5, 15),
    );
  });

  test('parses a date with a locale', () {
    expect('5/15/1990'.toDateTime(locale: 'en_US'), DateTime(1990, 5, 15));
  });

  test('prefers the pattern over the locale', () {
    expect(
      '15.05.1990'.toDateTime(locale: 'en_US', pattern: 'dd.MM.yyyy'),
      DateTime(1990, 5, 15),
    );
  });

  test('returns null for empty or unparsable input', () {
    expect(''.toDateTime(pattern: 'dd.MM.yyyy'), isNull);
    expect('date'.toDateTime(pattern: 'dd.MM.yyyy'), isNull);
    expect('1990-05-15'.toDateTime(locale: 'en_US'), isNull);
  });
}
