import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/week/event/event.dart';
import 'package:life_calendar/domain/models/week/goal/goal.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';

void main() {
  final week = Week(
    id: 42,
    yearId: 1,
    start: DateTime(2026, 10, 5),
    end: DateTime(2026, 10, 11, 23, 59, 59),
    tense: WeekTense.current,
    assessment: WeekAssessment.good,
    goals: const [Goal(id: 'g1', title: 'Run', isCompleted: true)],
    events: [Event(id: 'e1', title: 'Meeting', date: DateTime(2026, 10, 6))],
    resume: 'Good week',
    photos: const ['a.jpg'],
  );

  test('round-trips through a database row', () {
    expect(Week.fromJson(week.toJson()), week);
  });

  test('stores the tense as state and lists as json strings', () {
    final json = week.toJson();

    expect(json['state'], 'current');
    expect(json['assessment'], 'good');
    expect(json['start'], DateTime(2026, 10, 5).millisecondsSinceEpoch);
    expect(json['goals'], isA<String>());
    expect(json['events'], isA<String>());
    expect(json['photos'], '["a.jpg"]');
  });

  test('falls back to poor for an unknown assessment', () {
    final json = week.toJson()..['assessment'] = 'Хорошо';

    expect(Week.fromJson(json).assessment, WeekAssessment.poor);
  });

  test('reads a row without photos as an empty list', () {
    final json = week.toJson()..['photos'] = null;

    expect(Week.fromJson(json).photos, isEmpty);
  });

  test('empty week uses the injected time', () {
    final now = DateTime(2026, 10, 6, 9);
    final empty = Week.empty(time: () => now);

    expect(empty.id, -1);
    expect(empty.start, now);
    expect(empty.end, now);
    expect(empty.goals, isEmpty);
    expect(empty.events, isEmpty);
    expect(empty.photos, isEmpty);
  });
}
