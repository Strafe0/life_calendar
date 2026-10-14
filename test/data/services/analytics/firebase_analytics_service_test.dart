import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/services/analytics/firebase_analytics_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  test('registration sends only the birth year', () async {
    final firebase = _MockFirebaseAnalytics();
    when(
      () => firebase.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});

    await FirebaseAnalyticsService(
      firebase: firebase,
    ).logRegistration(DateTime(1990, 5, 17), 80);

    verify(
      () => firebase.logEvent(
        name: 'registration',
        parameters: {'birth_year': 1990, 'lifespan': 80},
      ),
    ).called(1);
  });
}
