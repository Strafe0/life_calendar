import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/converters/date_converter.dart';

void main() {
  const converter = DateConverter();
  final date = DateTime(2026, 10, 6, 12, 30, 15, 250);

  test('stores dates as milliseconds since epoch', () {
    expect(converter.toJson(date), date.millisecondsSinceEpoch);
  });

  test('round-trips a local date', () {
    expect(converter.fromJson(converter.toJson(date)), date);
  });

  test('parses milliseconds stored as a string', () {
    expect(converter.fromJson('${date.millisecondsSinceEpoch}'), date);
  });

  test('throws on a non numeric string', () {
    expect(() => converter.fromJson('2026-10-06'), throwsFormatException);
  });

  test('throws on an unsupported type', () {
    expect(() => converter.fromJson(1.5), throwsFormatException);
    expect(() => converter.fromJson(true), throwsFormatException);
  });
}
