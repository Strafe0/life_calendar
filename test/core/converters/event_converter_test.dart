import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/converters/event_converter.dart';
import 'package:life_calendar/domain/models/week/event/event.dart';

void main() {
  const converter = EventConverter();
  final events = [
    Event(id: 'e1', title: 'Meeting', date: DateTime(2026, 10, 6)),
    Event(id: 'e2', title: 'Party "big"', date: DateTime(2026, 10, 9, 20)),
  ];

  test('round-trips events', () {
    expect(converter.fromJson(converter.toJson(events)), events);
  });

  test('round-trips an empty list', () {
    expect(converter.toJson([]), '[]');
    expect(converter.fromJson('[]'), isEmpty);
  });

  test('stores dates as milliseconds since epoch', () {
    final json = jsonDecode(converter.toJson(events)) as List;

    expect(json.first, {
      'id': 'e1',
      'title': 'Meeting',
      'date': DateTime(2026, 10, 6).millisecondsSinceEpoch,
    });
  });

  test('generates an id for legacy events without one', () {
    final date = DateTime(2020, 1, 2);
    final parsed = converter.fromJson(
      '[{"title":"Old","date":${date.millisecondsSinceEpoch}}]',
    );

    expect(parsed.single.id, isNotEmpty);
    expect(parsed.single.title, 'Old');
    expect(parsed.single.date, date);
  });

  test('returns an empty list for malformed json', () {
    expect(converter.fromJson('not json'), isEmpty);
    expect(converter.fromJson('[{"title":'), isEmpty);
  });

  test('throws when the json is not a list of events', () {
    expect(() => converter.fromJson('null'), throwsA(isA<TypeError>()));
    expect(() => converter.fromJson('{}'), throwsA(isA<TypeError>()));
    expect(
      () => converter.fromJson('[{"id":"e1","date":0}]'),
      throwsA(isA<TypeError>()),
    );
  });
}
