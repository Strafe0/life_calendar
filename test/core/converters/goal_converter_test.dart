import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/converters/goal_converter.dart';
import 'package:life_calendar/domain/models/week/goal/goal.dart';

void main() {
  const converter = GoalConverter();
  const goals = [
    Goal(id: 'g1', title: 'Run', isCompleted: false),
    Goal(id: 'g2', title: 'Read, "slowly"', isCompleted: true),
  ];

  test('round-trips goals', () {
    expect(converter.fromJson(converter.toJson(goals)), goals);
  });

  test('round-trips an empty list', () {
    expect(converter.toJson([]), '[]');
    expect(converter.fromJson('[]'), isEmpty);
  });

  test('stores goals as a json list of objects', () {
    expect(jsonDecode(converter.toJson(goals)), [
      {'id': 'g1', 'title': 'Run', 'isCompleted': false},
      {'id': 'g2', 'title': 'Read, "slowly"', 'isCompleted': true},
    ]);
  });

  test('generates unique ids for legacy goals without one', () {
    final parsed = converter.fromJson(
      '[{"title":"A","isCompleted":false},{"title":"B","isCompleted":true}]',
    );

    expect(parsed.map((g) => g.title), ['A', 'B']);
    expect(parsed.map((g) => g.id), everyElement(isNotEmpty));
    expect(parsed.first.id, isNot(parsed.last.id));
  });

  test('returns an empty list for malformed json', () {
    expect(converter.fromJson(''), isEmpty);
    expect(converter.fromJson('[{"title":'), isEmpty);
  });

  test('throws when the json is not a list of goals', () {
    expect(() => converter.fromJson('null'), throwsA(isA<TypeError>()));
    expect(() => converter.fromJson('{}'), throwsA(isA<TypeError>()));
    expect(
      () => converter.fromJson('[{"id":"g1","title":"A"}]'),
      throwsA(isA<TypeError>()),
    );
  });
}
