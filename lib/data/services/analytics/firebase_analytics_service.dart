import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? firebase})
    : _firebase = firebase ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _firebase;

  @override
  Future<void> logAddWeekContent(WeekContentEvent type) async {
    await _firebase.logEvent(
      name: 'add_content',
      parameters: {'content_type': type.name},
    );
  }

  @override
  Future<void> logAssessmentChange(WeekAssessment assessement) async {
    await _firebase.logEvent(
      name: 'week_assessment',
      parameters: {'assessment': assessement.name},
    );
  }

  @override
  Future<void> logBackup(BackupEvent event) async {
    await _firebase.logEvent(
      name: 'backup',
      parameters: {'assessment': event.name},
    );
  }

  @override
  Future<void> logWeekOpening(WeekTransitionEvent event) async {
    await _firebase.logEvent(
      name: 'week_opening',
      parameters: {'open_type': event.name},
    );
  }

  @override
  Future<void> logChangeWeekContent(WeekContentEvent type) async {
    await _firebase.logEvent(
      name: 'change_content',
      parameters: {'content_type': type.name},
    );
  }

  @override
  Future<void> logDeleteWeekContent(WeekContentEvent type) async {
    await _firebase.logEvent(
      name: 'delete_content',
      parameters: {'content_type': type.name},
    );
  }

  @override
  Future<void> logDonate(DonateStep step) async {
    await _firebase.logEvent(name: 'donate', parameters: {'step': step.name});
  }

  @override
  Future<void> logChangeLifespan(int oldValue, int newValue) async {
    await _firebase.logEvent(
      name: 'change_lifespan',
      parameters: {'old_lifespan': oldValue, 'new_lifespan': newValue},
    );
  }

  @override
  Future<void> logRegistration(DateTime birthdate, int lifeSpan) async {
    await _firebase.logEvent(
      name: 'registration',
      // Only the year: the full birth date is personal data the app doesn't
      // need to send anywhere.
      parameters: {'birth_year': birthdate.year, 'lifespan': lifeSpan},
    );
  }
}
